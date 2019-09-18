# Freenom-DDNS

## How to use
### Download 
1. Clone or Download the project
2. copy `config.example` to `config`
3. edit `config` and input your freenom `email` `password` `domain_name` `domain_id`

    you can find `domain_id` on freenom manage domain page.
    
    like: https://my.freenom.com/clientarea.php?action=domaindetails&id={domain_id}

### Upload to Synology NAS
1. Log in to DSM
2. open **File Station**
3. create **freenom_ddns**  folder in the **download** folder
4. copy all files into **freenom_ddns** folder
  
### Schedule
1. Go to **Control Panel > Task Scheduler**
2. Create a task. **Create > Triggered Task > User-defined script**
3. input **Task Name**
4. Godo **Task Setting**, Under **Run Command**

```
. /volume1/download/freenom_ddns/check.sh
```

5. click **OK** and enable it.
