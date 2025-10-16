from django.urls import path
from main import views
from django.views.generic import RedirectView

urlpatterns = [
    path("home/", RedirectView.as_view(url="/", permanent=True)),
    path('', views.home, name='home'),

]
