# GLPI

Default accounts/passwords:

- glpi/glpi: administrator
- tech/tech: technician
- normal/normal: normal user
- post-only/postonly: post-only user

## Access to timezone database

Grant access to timezone database (mysql) to the user used by GLPI:

```sql
GRANT ALL PRIVILEGES ON mysql.* TO glpi;
```
