"""
WSGI config for inventory_service project.

It exposes the WSGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/1.6/howto/deployment/wsgi/
"""

import os
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "inventory_service.settings")

from django.core.wsgi import get_wsgi_application
application = get_wsgi_application()

# prime the wsgi application to trigger loading lazy assets,
# as otherwise the initial request is quite slow
try:
    from webtest import TestApp
    TestApp(application).get('/ping/')
except ImportError:
    print "webtest module isn't installed"
