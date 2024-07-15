#!/bin/bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
# Add your build commands here (e.g., collect static files)
deactivate
