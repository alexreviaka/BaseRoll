from enum import Enum
from typing import List

class Role(Enum):
    ADMIN = "admin"
    MANAGER = "manager"
    EMPLOYEE = "employee"

class Permission(Enum):
    CREATE_EMPLOYEE = "create_employee"
    PROCESS_PAYMENT = "process_payment"
    VIEW_ANALYTICS = "view_analytics"

ROLE_PERMISSIONS = {
    Role.ADMIN: [Permission.CREATE_EMPLOYEE, Permission.PROCESS_PAYMENT, Permission.VIEW_ANALYTICS],
    Role.MANAGER: [Permission.CREATE_EMPLOYEE, Permission.VIEW_ANALYTICS],
    Role.EMPLOYEE: []
}

def has_permission(role: Role, permission: Permission) -> bool:
    return permission in ROLE_PERMISSIONS.get(role, [])
