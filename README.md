Data model & REST API built on Ben's schema's and ideas
=======================================================

I wanted to see if I could do it with the Django ORM.  It looks like
we can:

```python
from inventory_service.models import *
from django.db.models import Count, Q

silver_material = Q(attributes__attribute__name='material', attributes__value='silver')
purity_999 = Q(attributes__attribute__name='purity', attributes__value='.999')
results = Item.objects.filter(silver_material | purity_999).annotate(clauses_matched=Count('id')).order_by().filter(clauses_matched=2)

print results
# [<Item: 2 'Silver Eagles'>]

# more generally
query_attrs = {
    'burr_size': '40mm',
    'has_motor': 'true',
}

clauses = Q()

for k, v in query_attrs.iteritems():
    clauses |= (Q(attributes__attribute__name=k) & Q(attributes__value=v))

results = Item.objects.filter(clauses).annotate(clauses_matched=Count('id')).order_by().filter(clauses_matched=len(query_attrs))
print results
# [<Item: 4 'Baratza Preciso'>]
```
