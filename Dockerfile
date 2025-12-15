# --- ESTÁGIO 1: BUILD (Compilação e Empacotamento) ---
# Usamos a tag 'builder' para referenciar este estágio mais tarde.
FROM gradle:jdk21-alpine AS builder

# Define o diretório de trabalho dentro do contêiner
WORKDIR /app

# Copia os arquivos de build (gradlew, settings.gradle, build.gradle) primeiro.
# Isso otimiza o cache do Docker, pois essas dependências mudam menos frequentemente
# do que o código-fonte.
COPY gradlew .
COPY settings.gradle .
COPY build.gradle .
COPY gradle.properties .
COPY gradle /app/gradle

# Instala as dependências (baixa libs externas), passo que pode ser cacheado
RUN ./gradlew dependencies --no-daemon

# Copia o restante do código-fonte da aplicação
COPY src /app/src

# Executa o build final: clean, compilação, testes e empacotamento em um JAR
RUN ./gradlew clean build --no-daemon

# --- ESTÁGIO 2: RUNTIME (Execução da Aplicação) ---
# Usamos uma imagem base menor, mais segura e otimizada para execução.
FROM openjdk:21-jre-slim-bullseye

# Define o diretório de trabalho dentro do contêiner final
WORKDIR /app

# Copia o JAR executável do estágio de 'builder'.
# Assumimos que o JAR final está em build/libs/*.jar
# O nome exato do JAR pode variar; ajuste se necessário.
COPY --from=builder /app/build/libs/*.jar app.jar

# Expõe a porta que sua aplicação Kotlin usa (ex: 8080 para muitas APIs web)
EXPOSE 8080

# Comando de entrada: define como a aplicação será iniciada
ENTRYPOINT ["java", "-jar", "app.jar"]