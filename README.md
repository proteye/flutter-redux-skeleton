# Flutter & Redux skeleton

Flutter and Redux skeleton mobile application.

## Features:
- redux
- redux thunk
- provider
- http requests
- authorization
- unit tests
- list and detail screen for example

## Run:
- ### Production
    ```
    flutter run --target lib/main_production.dart --flavor production
    ```
- ### Development
    ```
    flutter run --target lib/main_development.dart --flavor development
    ```
- ### Development-Production
    ```
    flutter run --target lib/main_devp.dart --flavor devp
    ```

## VS Code configuring
Please, create ./.vscode/launch.json configuration file and put it the next code:
```
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Dev",
            "type": "dart",
            "request": "launch",
            "program": "lib/main_development.dart",
            "args": [
                "--flavor",
                "development"
            ]
        },
        {
            "name": "DevP",
            "type": "dart",
            "request": "launch",
            "program": "lib/main_devp.dart",
            "args": [
                "--flavor",
                "devp"
            ]
        },
        {
            "name": "Prod",
            "type": "dart",
            "request": "launch",
            "program": "lib/main_production.dart",
            "args": [
                "--flavor",
                "production"
            ]
        }
    ]
}
```