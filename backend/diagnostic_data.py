import os
import django
from django.db.models import Sum, Count

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'core.settings')
django.setup()

from sales.models import Return, Refund, ReturnItem
from decimal import Decimal

print("--- Checking Returns ---")
returns = Return.objects.all()
for r in returns:
    try:
        print(f"Return {r.return_number}:")
        print(f"  Status: {r.status}")
        print(f"  Refund Amount: {r.refund_amount}")
        print(f"  Total Return Amount (Prop): {r.total_return_amount}")
        print(f"  Items Count (Prop): {r.items_count}")
        print(f"  Created By: {r.created_by.full_name if r.created_by else 'None'}")
    except Exception as e:
        print(f"  ERROR: {e}")

print("\n--- Checking Refunds ---")
refunds = Refund.objects.all()
for rf in refunds:
    try:
        print(f"Refund {rf.refund_number}:")
        print(f"  Status: {rf.status}")
        print(f"  Amount: {rf.amount}")
        print(f"  Return: {rf.return_request.return_number if rf.return_request else 'None'}")
        print(f"  Created By: {rf.created_by.full_name if rf.created_by else 'None'}")
    except Exception as e:
        print(f"  ERROR: {e}")

print("\n--- Checking Statistics Logic ---")
try:
    total_returns = Return.objects.filter(is_active=True).count()
    status_counts = Return.objects.filter(is_active=True).values('status').annotate(count=Count('id'))
    total_return_amount = Return.objects.filter(is_active=True).aggregate(total=Sum('refund_amount'))['total'] or Decimal('0.00')
    total_refund_amount = Refund.objects.filter(is_active=True, status='PROCESSED').aggregate(total=Sum('amount'))['total'] or Decimal('0.00')
    reason_counts = Return.objects.filter(is_active=True).values('reason').annotate(count=Count('id'))
    
    print(f"Total Returns: {total_returns}")
    print(f"Status Counts: {list(status_counts)}")
    print(f"Total Return Amount: {total_return_amount}")
    print(f"Total Refund Amount: {total_refund_amount}")
    print(f"Reason Counts: {list(reason_counts)}")
except Exception as e:
    print(f"STATISTICS ERROR: {e}")
    import traceback
    traceback.print_exc()
