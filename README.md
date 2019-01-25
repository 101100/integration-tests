Use Docker to set up SQL for integration tests:

## Ensure Docker is set up on your machine

Note that below you should replace `jasonh` with your Pandell username.

1. Install `docker` (from [here](https://download.docker.com/)) and `docker-machine` (from [here](https://github.com/docker/machine/releases/latest)).

2. Add your user to the `Hyper-V Administrators` group so that `docker-machine` can create a VM. From an administrative console, type:
    ```
    net localgroup "Hyper-V Administrators" NET\jasonh /add
    ```

3. Log out and back in (to capture new group).

4. Create Docker machine to run container in. The VM must have at least 2 GB of RAM for the Linux version of MS SQL Server
    ```
    docker-machine create --driver hyperv --hyperv-memory 4096 --hyperv-cpu-count 2 jasonh-docker-vm
    ```

5. Set environment variables so docker can connect to VM.  (This must be done once per terminal session if you don't add it to your profile.)
    ```
    & "$Env:CloudRoot\Apps\Bin\docker-machine.exe" env jasonh-docker-vm | Invoke-Expression
    ```

## Create container for integration tests

1. Create the SQL server container. You can do this directly with this command:
    ```
    docker run -d --name test-sqlserver --restart always -p 137-138:137-138/udp -p 139:139 -p 445:445 -p 1433:1433 101100/integration-tests
    ```

2. Determine your docker VM IP address:
    ```
    $DockerIpAddress = docker-machine ip jasonh-docker-vm
    Write-Host $DockerIpAddress
    ```

3. Set Pli SQL server environment variable.
    ```
    [Environment]::SetEnvironmentVariable("PLI_TEST_SQLSERVERS", "[{ host: '$DockerIpAddress', share: '\\\\$DockerIpAddress\\Temp', path: '/temp/', username: 'sa', password: 'p@ssw0rd' }]", "User")
    [Environment]::SetEnvironmentVariable("PLI_TEST_KEEPMDF", "true", "User")
    ```

    **Note**: if you are updating upgrade tasks, you may need to clear out the saved templates:
    ```
    $DockerIpAddress = docker-machine ip jasonh-docker-vm
    Remove-Item -Force \\$DockerIpAddress\temp\*.mdf
    ```

4. Run tests!
    ```
    .\IntegrationTest-Debug.cmd
    ```

    **Note**: if you want to run tests from an IDE, you will need to restart it after setting the environment variable.

Advantages:
- No Windows server install.
- Learn a new technology!

Disadvantage:
- Tests run slow...  I'm going to get an exact comparison, but it seems slower.
- SQL version is not exactly the same (could be an advantage when you also consider that TeamCity will use the "correct" version).
