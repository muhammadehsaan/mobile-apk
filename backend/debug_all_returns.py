import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'core.settings')
django.setup()

from sales.models import Return
from sales.return_serializers import ReturnListSerializer

returns = Return.objects.all()
print(f"Found {returns.count()} returns")
for r in returns:
    try:
        data = ReturnListSerializer(r).data
        print(f"Return {r.return_number}: OK")
    except Exception as e:
        print(f"Return {r.return_number}: ERROR {e}")
        import traceback
        traceback.print_exc()
