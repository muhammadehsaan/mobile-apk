import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'core.settings')
django.setup()

from rest_framework.test import APIRequestFactory, force_authenticate
from django.contrib.auth import get_user_model
from sales.return_views import ReturnListView

User = get_user_model()
user = User.objects.filter(is_superuser=True).first()

factory = APIRequestFactory()
request = factory.get('/api/v1/sales/returns/')
force_authenticate(request, user=user)

view = ReturnListView.as_view()
try:
    response = view(request)
    print(f"Status Code: {response.status_code}")
except Exception as e:
    print(f"Error: {e}")
    import traceback
    traceback.print_exc()
