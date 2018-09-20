# PostgreSQL Data Dictionary (pgdd)

The PostgreSQL Data Dictionary project makes it easy to provide a usable data dictionary
accessible to all all users of a PostgreSQL database.

##Install data dictionary

### Clone repo

```
cd ~/git
git clone https://github.com/rustprooflabs/pgdd.git
cd ~/git/pgdd
```

### Deploy `dd` schema w/ Sqitch

```
cd ~/git/pgdd/db
sqitch deploy db:pg://<pg_username>@<pg_server>:<pg_port>/<db_name>
```

e.g.

```
cd ~/git/pgdd/db
sqitch deploy db:pg://youruser@192.168.2.15:5423/piws
```

