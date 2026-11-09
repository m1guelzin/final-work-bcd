
--Criação das tabelas (Modelagem Física)

-- Apaga as tabelas caso já existam (para poder rodar o script de novo)
DROP VIEW  IF EXISTS vw_animal_idade;
DROP VIEW  IF EXISTS vw_consulta_valor_total;
DROP TABLE IF EXISTS prescricao;
DROP TABLE IF EXISTS consulta;
DROP TABLE IF EXISTS medicamento;
DROP TABLE IF EXISTS veterinario;
DROP TABLE IF EXISTS prontuario;
DROP TABLE IF EXISTS animal;
DROP TABLE IF EXISTS tutor_telefone;
DROP TABLE IF EXISTS tutor;


-- TUTOR: dono do animal.
CREATE TABLE tutor (
    id_tutor        SERIAL PRIMARY KEY,
    nome            VARCHAR(100) NOT NULL,
    cpf             VARCHAR(14)  NOT NULL UNIQUE,
    email           VARCHAR(100) NOT NULL UNIQUE,
    data_nascimento DATE         NOT NULL,
    logradouro      VARCHAR(100) NOT NULL,
    numero          VARCHAR(10)  NOT NULL,
    bairro          VARCHAR(50)  NOT NULL,
    cidade          VARCHAR(50)  NOT NULL,
    uf              CHAR(2)      NOT NULL,
    cep             VARCHAR(9)   NOT NULL,
    data_cadastro   DATE         NOT NULL
);


-- TUTOR_TELEFONE: o telefone é um atributo MULTIVALORADO
CREATE TABLE tutor_telefone (
    id_telefone SERIAL PRIMARY KEY,
    id_tutor    INT         NOT NULL REFERENCES tutor (id_tutor),
    numero      VARCHAR(15) NOT NULL,
    tipo        VARCHAR(15) NOT NULL CHECK (tipo IN ('Celular', 'Residencial'))
);


-- ANIMAL: paciente da clínica. Um tutor tem vários animais (1:N).
CREATE TABLE animal (
    id_animal       SERIAL PRIMARY KEY,
    id_tutor        INT          NOT NULL REFERENCES tutor (id_tutor),
    nome            VARCHAR(50)  NOT NULL,
    especie         VARCHAR(20)  NOT NULL CHECK (especie IN ('Cão', 'Gato', 'Ave', 'Coelho')),
    raca            VARCHAR(50)  NOT NULL,
    sexo            CHAR(1)      NOT NULL CHECK (sexo IN ('M', 'F')),
    data_nascimento DATE         NOT NULL,
    peso_kg         DECIMAL(5,2) NOT NULL CHECK (peso_kg > 0)
);


-- PRONTUARIO: ficha do animal. Cada animal tem um único prontuário (1:1).
CREATE TABLE prontuario (
    id_prontuario     SERIAL PRIMARY KEY,
    id_animal         INT         NOT NULL UNIQUE REFERENCES animal (id_animal),
    numero_prontuario VARCHAR(10) NOT NULL UNIQUE,
    data_abertura     DATE        NOT NULL,
    castrado          BOOLEAN     NOT NULL,
    alergias          VARCHAR(100),
    observacoes       VARCHAR(200)
);


-- VETERINARIO: médico veterinário da rede.
CREATE TABLE veterinario (
    id_veterinario SERIAL PRIMARY KEY,
    nome           VARCHAR(100)  NOT NULL,
    crmv           VARCHAR(15)   NOT NULL UNIQUE,
    especialidade  VARCHAR(50)   NOT NULL,
    email          VARCHAR(100)  NOT NULL UNIQUE,
    data_admissao  DATE          NOT NULL,
    salario        DECIMAL(10,2) NOT NULL CHECK (salario > 0)
);


-- MEDICAMENTO: medicamentos vendidos na farmácia da rede.
CREATE TABLE medicamento (
    id_medicamento  SERIAL PRIMARY KEY,
    nome_comercial  VARCHAR(100)  NOT NULL UNIQUE,
    principio_ativo VARCHAR(50)   NOT NULL,
    forma           VARCHAR(30)   NOT NULL,
    fabricante      VARCHAR(50)   NOT NULL,
    preco_unitario  DECIMAL(10,2) NOT NULL CHECK (preco_unitario > 0),
    estoque         INT           NOT NULL CHECK (estoque >= 0)
);


-- CONSULTA: atendimento de um animal por um veterinário.
-- Um animal tem várias consultas (1:N) e um veterinário faz várias consultas (1:N).
-- O valor total é um atributo DERIVADO: é calculado na view vw_consulta_valor_total.
CREATE TABLE consulta (
    id_consulta    SERIAL PRIMARY KEY,
    id_animal      INT           NOT NULL REFERENCES animal (id_animal),
    id_veterinario INT           NOT NULL REFERENCES veterinario (id_veterinario),
    data_hora      TIMESTAMP     NOT NULL,
    tipo           VARCHAR(20)   NOT NULL CHECK (tipo IN ('Rotina', 'Retorno', 'Vacinação', 'Emergência', 'Cirurgia')),
    motivo         VARCHAR(100)  NOT NULL,
    diagnostico    VARCHAR(100),
    valor_consulta DECIMAL(10,2) NOT NULL CHECK (valor_consulta >= 0),
    status         VARCHAR(20)   NOT NULL CHECK (status IN ('Agendada', 'Realizada', 'Cancelada'))
);


-- PRESCRICAO: resolve o relacionamento N:N entre CONSULTA e MEDICAMENTO
-- (uma consulta pode ter vários medicamentos e um medicamento aparece em várias consultas).
-- A chave primária é composta pelas duas chaves estrangeiras.
CREATE TABLE prescricao (
    id_consulta    INT           NOT NULL REFERENCES consulta (id_consulta),
    id_medicamento INT           NOT NULL REFERENCES medicamento (id_medicamento),
    quantidade     INT           NOT NULL CHECK (quantidade > 0),
    posologia      VARCHAR(100)  NOT NULL,
    valor_unitario DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (id_consulta, id_medicamento)
);


-- VIEW do atributo derivado IDADE (calculada a partir da data de nascimento)
CREATE VIEW vw_animal_idade AS
SELECT id_animal,
       nome,
       data_nascimento,
       EXTRACT(YEAR FROM AGE(CURRENT_DATE, data_nascimento)) AS idade
FROM animal;


-- VIEW do atributo derivado VALOR TOTAL da consulta
-- (valor da consulta + soma dos medicamentos prescritos)
CREATE VIEW vw_consulta_valor_total AS
SELECT c.id_consulta,
       c.valor_consulta,
       c.valor_consulta + COALESCE(SUM(p.quantidade * p.valor_unitario), 0) AS valor_total
FROM consulta c
LEFT JOIN prescricao p ON p.id_consulta = c.id_consulta
GROUP BY c.id_consulta, c.valor_consulta;
