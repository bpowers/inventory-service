"Models for inventory management REST service"
from django.db import models

class Attribute(models.Model):
    name = models.CharField(max_length=100)

    def __unicode__(self):
        return "%s '%s'" % (self.id, self.name)


class AttributeVal(models.Model):
    attribute = models.ForeignKey(Attribute)
    value = models.CharField(max_length=200)

    def __unicode__(self):
        return "%s '%s:%s'" % (self.id, self.attribute.name, self.value)

class Item(models.Model):
    name = models.CharField(max_length=250)
    description = models.CharField(max_length=500, blank=True)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    shipping = models.DecimalField(max_digits=6, decimal_places=2)
    # TODO: currency
    inventory = models.IntegerField()
    attributes = models.ManyToManyField(AttributeVal, related_name='items', null=True)

    def __unicode__(self):
        return "%s '%s'" % (self.id, self.name)

class Category(models.Model):
    name = models.CharField(max_length=100)
    items = models.ManyToManyField(Item, related_name='categories', null=True)
    attributes = models.ManyToManyField(Attribute, 'categories', null=True)

    def __unicode__(self):
        return "%s '%s'" % (self.id, self.name)
