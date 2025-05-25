FROM mcr.microsoft.com/playwright/python:v1.52.0-noble
WORKDIR /app

COPY requirements.txt /app
RUN pip install --no-cache-dir -r requirements.txt

COPY . /app

CMD ["python", "main.py"]
