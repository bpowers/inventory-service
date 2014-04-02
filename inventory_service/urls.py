from django.conf.urls import patterns, include, url

from django.contrib import admin
admin.autodiscover()

from .models import *
from rest_framework import routers, viewsets, serializers

class ItemSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Item
        depth = 2

class AttributeViewSet(viewsets.ModelViewSet):
    model = Attribute

class AttributeValViewSet(viewsets.ModelViewSet):
    model = AttributeVal

class ItemViewSet(viewsets.ModelViewSet):
    model = Item
    serializer_class = ItemSerializer

class CategoryViewSet(viewsets.ModelViewSet):
    model = Category


router = routers.DefaultRouter()
router.register(r'attribute', AttributeViewSet)
router.register(r'attribute_val', AttributeValViewSet)
router.register(r'category', CategoryViewSet)
router.register(r'item', ItemViewSet)


urlpatterns = patterns('',
    # Examples:
    # url(r'^$', 'inventory_service.views.home', name='home'),
    # url(r'^blog/', include('blog.urls')),
    url(r'^', include(router.urls)),
    url(r'^api-auth/', include('rest_framework.urls', namespace='rest_framework')),
    url(r'^admin/', include(admin.site.urls)),
)
