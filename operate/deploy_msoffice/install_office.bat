@ECHO OFF
ECHO "You need Office Deployment tools (setup.exe): https://www.microsoft.com/en-us/download/details.aspx?id=49117"
ECHO "Direct link to ODT install: https://www.microsoft.com/en-us/download/confirmation.aspx?id=49117"
ECHO "Please update your license keys in the XML file before running the installer!"
ECHO Install Office: setup.exe /configure office219_only.xml
ECHO Create install material only: setup.exe /download office219_only.xml
