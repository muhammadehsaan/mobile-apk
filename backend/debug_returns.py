import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'core.settings')
django.setup()

from sales.models import Return
from sales.return_serializers import ReturnListSerializer

try:
    returns = Return.objects.filter(is_active=True).select_related(
        'sale', 'customer', 'approved_by', 'processed_by', 'created_by'
    ).prefetch_related('return_items')
    
    serializer = ReturnListSerializer(returns, many=True)
    print(f"Serialized {len(serializer.data)} returns")
except Exception as e:
    print(f"Error: {e}")
    import traceback
    traceback.print_exc()
