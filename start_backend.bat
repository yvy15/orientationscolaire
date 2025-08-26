@echo off
echo ========================================
echo   Demarrage du Backend Spring Boot
echo ========================================
echo.

echo Verifying Java installation...
java -version
if %errorlevel% neq 0 (
    echo ERROR: Java n'est pas installe ou n'est pas dans le PATH
    echo Veuillez installer Java 17+ et reessayer
    pause
    exit /b 1
)

echo.
echo Verifying Maven installation...
mvn -version
if %errorlevel% neq 0 (
    echo ERROR: Maven n'est pas installe ou n'est pas dans le PATH
    echo Veuillez installer Maven et reessayer
    pause
    exit /b 1
)

echo.
echo Demarrage du backend...
echo L'API sera accessible sur: http://localhost:8080
echo Console H2: http://localhost:8080/h2-console
echo.

cd Backend
mvn spring-boot:run

echo.
echo Backend arrete.
pause


