// build.gradle.kts
plugins {
    kotlin("jvm") version "1.9.22"
    id("org.jlleitschuh.gradle.ktlint") version "12.1.1"
}

group = "com.exemplo"
version = "1.0-SNAPSHOT"

repositories {
    mavenCentral()
}

dependencies {
    implementation(kotlin("stdlib-jdk8"))
}

ktlint {
    filter {
        exclude("**/generated/**")
    }
}
