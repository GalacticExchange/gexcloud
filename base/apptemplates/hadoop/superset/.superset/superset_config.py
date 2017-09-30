import os
import json

MAPBOX_API_KEY = os.getenv('MAPBOX_API_KEY', 'pk.eyJ1IjoiZ2FsYWN0aWNleGNoYW5nZSIsImEiOiJjajRxcmx6a2MycmE1MnFvNG5zZXM4MHd1In0.iJx11qRRx_SombRlyTXWqw')

SQLALCHEMY_DATABASE_URI = 'sqlite:////home/superset/.superset/superset.db'
SECRET_KEY = 'thisISaSECRET_1234'
