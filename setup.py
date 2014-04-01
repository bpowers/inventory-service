import os
from setuptools import setup, find_packages
import inventory_service

setup(name='inventory_service',
      version=inventory_service.__version__,
      description='Inventory management service',
      author='Bobby Powers',
      author_email='bobbypowers@gmail.com',
      url='http://inventory.bpowers.net',
      packages=find_packages(),
      classifiers=[
          'Framework :: Django',
          'Development Status :: 4 - Beta',
          'Environment :: Web Environment',
          'Programming Language :: Python',
          'Intended Audience :: Developers',
          'Operating System :: OS Independent',
          'Topic :: Software Development :: Libraries :: Python Modules',],
      include_package_data=True,
      package_data={ 'facebook_analytics_service': ['templates/*.html', 'templates/*.txt', 'fixtures/*.json', 'migrations/*.py', 'mocks/*.json']},
      zip_safe=False,
      )
