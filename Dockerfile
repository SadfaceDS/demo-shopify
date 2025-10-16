FROM python:3.11-bullseye AS builder

WORKDIR /billFirstClient


RUN apt-get update && apt-get install -y --no-install-recommends \
    libglib2.0-0 \
    libglib2.0-dev \
    libgirepository-1.0-1 \
    gir1.2-glib-2.0 \
    gobject-introspection \
    python3-gi \
    libcairo2 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libpangoft2-1.0-0 \
    libjpeg-dev \
    libpng-dev \
    libgdk-pixbuf2.0-dev \
    fonts-liberation \
    && ln -s /usr/lib/x86_64-linux-gnu/libgobject-2.0.so.0 /usr/lib/libgobject-2.0-0 \
    && ln -s /usr/lib/x86_64-linux-gnu/libgobject-2.0.so.0 /usr/lib/x86_64-linux-gnu/libgobject-2.0-0 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*


RUN apt-get update && apt-get install -y python3 python3-pip

COPY requirements.txt .
RUN pip install --upgrade pip && pip install --prefix=/install gunicorn -r requirements.txt

FROM python:3.11-bullseye

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    DJANGO_SETTINGS_MODULE=billFirstClient.settings \
    TZ=EST \
    DJANGO_ENV=production \
    SECRET_KEY=''

WORKDIR /billFirstClient

COPY --from=builder /install /usr/local

COPY . /billFirstClient

RUN adduser --disabled-password --no-create-home djangouser && chown -R djangouser:djangouser /billFirstClient
RUN mkdir -p /app/staticfiles/img && chown -R djangouser:djangouser /app/staticfiles

USER djangouser

EXPOSE 8000

CMD ["gunicorn", "billFirstClient.wsgi:application", "--bind", "0.0.0.0:8000", "--workers=3", "--timeout=120"]

