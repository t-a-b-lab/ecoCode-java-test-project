#!/usr/bin/env sh

function usage {
  echo ""
  echo "Usage: $0 -t|--token <Sonar analysis token> [-m|--mode <docker|maven>] [-n|--network <network identifier>] [-u|--url <sonar instance url>]  [-p|--project <path to root of project to analyze]"
  echo ""
  echo "Run the analysis on the given project and send the result to the provided sonar instance"
  echo ""
  echo "Options:"
  echo "  -d, --delete     Delete the stuff."
  exit 1
}

while [[ $# -gt 0 ]] do
  case $1 in

    -t|--token)
      TOKEN="$2"
      shift
      shift

    -m|--mode)
      MODE="$2"
      shift
      shift

    -n|--network)
      NETWORK_NAME="$2"
      shift
      shift

    -u|--url)
      SONAR_URL="$2"
      shift
      shift

    -p|--project)
      PROJECT="$2"
      shift
      shift

    -h|--help)
      usage
      shift

    *)
      echo "Invalid option: $1"
      usage
  esac
done

if [ -z "$MODE" ] then
  MODE="docker"
elif [[ ! "$MODE" =~ ^(docker|maven)$ ]] then
  echo "Invalid mode. Possible mode are docker or maven"
fi

if [ -eq "$MODE" == "docker" ] && [ -z "$NETWORK_NAME" ]
  NETWORK_NAME="sonarnet"
fi

if [ -eq "$MODE" == "docker" ] && [ -z "$SONAR_URL" ]
  SONAR_URL="http://sonar:9000"
fi

if [ -eq "$MODE" == "docker" ] && [ -z "$PROJECT" ]
  $PROJECT="."
fi


if [ -eq "$MODE" == "docker" ]
   docker run --rm -e SONAR_HOST_URL="$SONAR_URL" -v "$PROJECT/:/usr/src" --network $NETWORK_NAME sonarsource/sonar-scanner-cli
fi
# "sonar.token" variable (or sonar.login before SONARQUBE 9.9) : private TOKEN generated in your local SonarQube during installation
# (input paramater of this script)
if [-eq "$MODE" == "maven"]
  $PROJECT/mvnw clean org.sonarsource.scanner.maven:sonar-maven-plugin:3.9.1.2184:sonar -Dsonar.token=$TOKEN
fi
# mvn org.sonarsource.scanner.maven:sonar-maven-plugin:3.9.1.2184:sonar -Dsonar.token=$1 -Dsonar.host.url=https://sonar-staging.gcp.cicd.solocal.com/

# command if you have a SONARQUBE < 9.9 (sonar.token existing for SONARQUBE >= 10.0)
# mvn org.sonarsource.scanner.maven:sonar-maven-plugin:3.9.1.2184:sonar -Dsonar.login=$1

