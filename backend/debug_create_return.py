import os
import django
from decimal import Decimal

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'core.settings')
django.setup()

from sales.models import Sales, Return
from sales.return_serializers import ReturnCreateSerializer
from django.contrib.auth import get_user_model

User = get_user_model()
user = User.objects.filter(is_superuser=True).first()

# Get a sale
sale = Sales.objects.filter(is_active=True).first()
if not sale:
    print("No sales found")
    exit()

sale_item = sale.sale_items.filter(is_active=True).first()
if not sale_item:
    print("No sale items found")
    exit()

data = {
    'sale': str(sale.id),
    'customer': str(sale.customer.id) if sale.customer else None,
    'reason': 'OTHER',
    'return_items': [
        {
            'sale_item_id': str(sale_item.id),
            'quantity_returned': 1,
            'condition': 'GOOD'
        }
    ]
}

serializer = ReturnCreateSerializer(data=data)
if serializer.is_valid():
    ret = serializer.save(created_by=user)
    print(f"Created return {ret.return_number}")
else:
    print(f"Error: {serializer.errors}")
