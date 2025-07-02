FROM python:3.13-slim-bookworm

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /code

COPY requirements.txt /code/
RUN pip install --upgrade pip && pip install -r requirements.txt
#RUN pip install --no-cache-dir -r requirements.txt

COPY . /code/
RUN python manage.py collectstatic --noinput

RUN chmod +x /code/entrypoint.sh

# CMD ["./entrypoint.sh"]
CMD ["sh", "-c", "python manage.py migrate && python manage.py runserver 0.0.0.0:8000"]

