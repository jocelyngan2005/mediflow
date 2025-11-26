# Simple token logic 

import secrets
import os
from dotenv import load_dotenv

load_dotenv()

# Load the secret once here
# In production, ensure this is a strong, random string
CLINIC_SECRET_CODE = os.getenv("CLINIC_SECRET_CODE", "MEDIFLOW-ADMIN-2024")

def verify_code_securely(input_code: str) -> bool:
    """
    Securely compares the input code with the stored secret.
    Using 'secrets.compare_digest' prevents timing attacks, 
    where hackers guess the password based on how long the comparison takes.
    """
    if not input_code:
        return False
        
    # Returns True if they match, False otherwise
    return secrets.compare_digest(input_code, CLINIC_SECRET_CODE)



"""
**How to integrate this into `dependencies.py`:**
You would update your `dependencies.py` to import this function:
```python
from app.core.security import verify_code_securely

async def verify_staff_token(x_clinic_code: str = Header(...)):
    if not verify_code_securely(x_clinic_code):
        raise HTTPException(...) 
"""