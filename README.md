# Freenom-DDNS

## Copy config and edit
```bash
cp config.example config
vim config
```

## Run
```bash
./check.sh
```

## Cronjob
```
# run at every hour
0 * * * * . /path/check.sh
```