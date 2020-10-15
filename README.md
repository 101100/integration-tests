This docker image provides SQL Server along with a shared path that is accesible
via an SMB share to facilitate backup file movement.


## Setting it up

To use this image, run it with Docker:

```
docker run -d --name sqlserver --restart always -p 137-138:137-138/udp -p 139:139 -p 445:445 -p 1433:1433 101100/integration-tests
```

- You can pass in other [SQL Server configuration environment variables](https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-configure-environment-variables?view=sql-server-linux-2017) by adding `-e` flags on the command.  For instance, you can use a different edition of SQL server (e.g. “Developer”, “Standard” or “Enterprise”) with the `MSSQL_PID` flag. All together, this would require adding something like `-e "MSSQL_PID=Standard"` to the above command.
- By default, the `sa` user password and share password are both `p@ssw0rd`. You can change the password by setting the `SA_PASSWORD` environment variable.

The share has a path of `SqlBackups` and is available inside the container at `/sqlbackups`. If you are using Windows, you can preset the password that windows will use to connect to the share using the `net` command. If Docker is running in a VM and that VM is available as the hostname `docker-vm`, then the command would be:

```
net use \\docker-vm\SqlBackups /user:root p@ssw0rd
```


## Re-creating the image from the GitHub repo

If you chose these steps, you can use your image instead of
`101100/integration-tests`.  Note that below you should replace `101100` with
your Docker Hub username.

1. Clone the repository:
    ```
    git clone git@github.com:101100/integration-tests.git
    ```

2. Build the container:
    ```
    docker build -t integration-tests .
    ```

3. (Optional) Log in using `docker login`, tag the image and push it container to Docker Hub:
    ```
    docker tag integration-tests 101100/integration-tests:copy-of-MS-tag
    docker tag integration-tests 101100/integration-tests:latest
    docker push 101100/integration-tests:copy-of-MS-tag
    docker push 101100/integration-tests:latest
    ```
