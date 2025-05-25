import logging
import os
import sys

from dotenv import load_dotenv

from avanza import get_avanza_balance
from ynab import get_ynab_balance, adjust_ynab_balance


# Configure log level as INFO, unless overriden by environment
logging.basicConfig(level=os.environ.get("LOGLEVEL", "INFO"))
log = logging.getLogger("avanza-ynab-sync")

# Load environment variables from .env file
load_dotenv()


def main():
    AZA_USERNAME = os.getenv("AZA_USERNAME")
    AZA_PASSWORD = os.getenv("AZA_PASSWORD")
    AZA_TOTP_SECRET = os.getenv("AZA_TOTP_SECRET")

    YNAB_TOKEN = os.getenv("YNAB_TOKEN")
    YNAB_BUDGET = os.getenv("YNAB_BUDGET")
    YNAB_ACCOUNT = os.getenv("YNAB_ACCOUNT")

    if not AZA_USERNAME or not AZA_PASSWORD or not AZA_TOTP_SECRET:
        log.error("Avanza credentials are missing.")
        return 1

    if not YNAB_TOKEN or not YNAB_BUDGET or not YNAB_ACCOUNT:
        log.error("YNAB API credentials are missing.")
        return 1

    # Get latest balance from Avanza
    new_balance = get_avanza_balance(AZA_USERNAME, AZA_PASSWORD, AZA_TOTP_SECRET)
    if new_balance is None:
        log.error("Failed to get Avanza balance.")
        return 1
    else:
        log.info(f"Total balance in Avanza: {new_balance}")

    # Get Ynab balance
    old_balance = get_ynab_balance(YNAB_TOKEN, YNAB_BUDGET, YNAB_ACCOUNT)
    if old_balance is None:
        log.error("Failed to get YNAB balance.")
        return 1
    else:
        log.info(f"Total balance in YNAB: {old_balance}")

    # Calculate the difference
    difference = new_balance - old_balance
    log.info(f"Difference between Coinbase and YNAB: {difference}")

    # Send an adjustment transaction to Ynab
    success = adjust_ynab_balance(YNAB_TOKEN, YNAB_BUDGET, YNAB_ACCOUNT, difference)
    if success:
        log.info("Balance adjustment sent to YNAB.")
        return 0
    else:
        log.error("Failed to send balance adjustment to YNAB.")
        return 1


if __name__ == "__main__":
    sys.exit(main())
