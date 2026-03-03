import os
import django
from django.db import connection

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'core.settings')
django.setup()

from sales.models import Return
from sales.return_serializers import ReturnListSerializer

print("--- Data Check ---")
for r in Return.objects.all():
    print(f"Return: {r.return_number}, status: {r.status}, reason: {r.reason}")

print("\n--- Serializer Check ---")
try:
    returns = Return.objects.all()
    serializer = ReturnListSerializer(returns, many=True)
    # Accessing data triggers the serialization
    data = serializer.data
    print(f"Serialized {len(data)} items")
except Exception as e:
    print(f"ERROR: {e}")
    import traceback
    traceback.print_exc()

print("\n--- QuerySet Check ---")
try:
    from sales.return_views import ReturnListView
    from rest_framework.test import APIRequestFactory
    
    factory = APIRequestFactory()
    request = factory.get('/api/v1/sales/returns/')
    
    view = ReturnListView()
    view.request = request
    view.format_kwarg = None
    
    qs = view.get_queryset()
    print(f"QuerySet contains {qs.count()} items")
    for item in qs:
        print(f"  - {item}")
except Exception as e:
    print(f"ERROR in get_queryset: {e}")
    import traceback
    traceback.print_exc()
