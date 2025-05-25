import hashlib
import logging
import os
import pyotp

from playwright.sync_api import sync_playwright
from playwright.sync_api import Error as PlaywrightError

log = logging.getLogger("avanza-ynab-sync")


def get_avanza_balance(username, password, totp_secret):
    """Retrieves the total Avanza balance."""
    totp = _generate_totp(totp_secret)
    balance = _scrape_avanza_for_balance(username, password, totp)
    return balance


def _generate_totp(totp_secret):
    """Generates a TOTP code from a given secret."""
    totp = pyotp.TOTP(totp_secret, digest=hashlib.sha1)
    return totp.now()


def _scrape_avanza_for_balance(username, password, totp):
    """Logs into Avanza using 2FA and scrapes the total account balance."""
    with sync_playwright() as playwright:
        try:
            browser = playwright.chromium.launch(headless=True)
            page = browser.new_page()
            url = "https://www.avanza.se"
            log.debug(f"Navigating to: {url}")

            page.goto(url)
            page.get_by_role("button", name="Godkänn alla cookies").click()
            page.get_by_role("button", name="Logga in", exact=True).click()
            page.get_by_role("radio", name="Användarnamn").click()
            page.get_by_role("textbox", name="Användarnamn").fill(username)
            page.get_by_role("textbox", name="Lösenord").fill(password)
            page.get_by_role("button", name="Logga in").click()
            page.get_by_role("textbox", name="Mata in koden som visas i din").fill(totp)
            page.get_by_role("link", name="Min ekonomi").click()

            page.locator("[data-analytics-label='Totalt värde']").click()

            # Find total balance tag in side panel
            tag = (
                page.locator("aza-total-values-breakdown")
                .locator("aza-numerical")
                .first
            )

            # Clean things up and parse
            balance = float(
                tag.text_content()
                .replace("krkronor", "")
                .replace("\xa0", "")
                .replace(" ", "")
                .replace(",", ".")
            )

            return balance

        except PlaywrightError as e:
            log.error(f"An error occurred during browser/page interaction: {e}")
        except Exception as e:
            log.error(f"An unexpected error occurred: {e}")
        finally:
            if "browser" in locals() and browser:
                browser.close()
                log.debug("Browser closed.")
