# Quick Start Java Project

A simple Java Maven project that can be used as a base to quickly standup a new Java application.

## Usage

1. Open a BASH shell
2. `cd` into directory for the new project (directory must be empty)
3. Run the following
```bash
git clone -o quickstart https://github.com/baincd/quickstart-java-project.git . && 
./init.sh
```

## Appendix

<details>
<summary>Useful commands for creating a new Java project</summary>

```bash
# Use the maven-archetype-quickstart archetype to generate a new project
mvn archetype:generate -DarchetypeGroupId=org.apache.maven.archetypes -DarchetypeArtifactId=maven-archetype-quickstart

# Create .gitignore
curl -sL https://www.toptal.com/developers/gitignore/api/java,maven,intellij,eclipse,visualstudiocode > .gitignore
```

</details>



