-- CRUD 

-- CREATE (INSERT): cadastrando um cliente novo

-- 1) Novo tutor
INSERT INTO tutor (nome, cpf, email, data_nascimento, logradouro, numero,
                   bairro, cidade, uf, cep, data_cadastro)
VALUES ('Felipe Souza', '999.888.777-66', 'felipe.souza@email.com', '2002-05-14',
        'Rua das Acácias', '120', 'Centro', 'Curitiba', 'PR', '80010-120', CURRENT_DATE);

-- 2) Telefone do tutor (busca o id do tutor pelo CPF)
INSERT INTO tutor_telefone (id_tutor, numero, tipo)
VALUES ((SELECT id_tutor FROM tutor WHERE cpf = '999.888.777-66'), '(41) 99876-5432', 'Celular');

-- 3) Animal do tutor
INSERT INTO animal (id_tutor, nome, especie, raca, sexo, data_nascimento, peso_kg)
VALUES ((SELECT id_tutor FROM tutor WHERE cpf = '999.888.777-66'),
        'Paçoca', 'Cão', 'SRD', 'M', '2023-02-10', 12.40);

-- 4) Prontuário do animal
INSERT INTO prontuario (id_animal, numero_prontuario, data_abertura, castrado, alergias)
VALUES ((SELECT MAX(id_animal) FROM animal), 'PV-99999', CURRENT_DATE, FALSE, 'Dipirona');

-- 5) Consulta agendada para o animal com o veterinário 1
INSERT INTO consulta (id_animal, id_veterinario, data_hora, tipo, motivo, valor_consulta, status)
VALUES ((SELECT MAX(id_animal) FROM animal), 1, '2026-12-15 10:00', 'Rotina',
        'Check-up anual', 180.00, 'Agendada');


-- READ (SELECT): consultando o que foi cadastrado

-- 6) Dados do tutor, do telefone, do animal e da consulta juntos
SELECT t.nome        AS tutor,
       tf.numero     AS telefone,
       a.nome        AS animal,
       a.especie,
       p.numero_prontuario,
       c.data_hora,
       v.nome        AS veterinario,
       c.status
FROM tutor t
JOIN tutor_telefone tf ON tf.id_tutor = t.id_tutor
JOIN animal a          ON a.id_tutor = t.id_tutor
JOIN prontuario p      ON p.id_animal = a.id_animal
JOIN consulta c        ON c.id_animal = a.id_animal
JOIN veterinario v     ON v.id_veterinario = c.id_veterinario
WHERE t.cpf = '999.888.777-66';


-- UPDATE: alterando dados

-- 7) O tutor mudou de endereço
UPDATE tutor
SET logradouro = 'Avenida Sete de Setembro',
    numero     = '2500',
    bairro     = 'Batel',
    cep        = '80230-010'
WHERE cpf = '999.888.777-66';

-- 8) A consulta aconteceu: muda o status e registra o diagnóstico
UPDATE consulta
SET status = 'Realizada',
    diagnostico = 'Animal saudável'
WHERE id_animal = (SELECT MAX(id_animal) FROM animal);

-- 9) Conferindo as alterações
SELECT t.nome, t.logradouro, t.numero, t.bairro, c.status, c.diagnostico
FROM tutor t
JOIN animal a   ON a.id_tutor = t.id_tutor
JOIN consulta c ON c.id_animal = a.id_animal
WHERE t.cpf = '999.888.777-66';


-- DELETE: excluindo dados

-- 10) Tentar apagar o tutor direto dá ERRO, porque ele ainda tem
--     telefone e animal ligados a ele (integridade referencial).
DELETE FROM tutor WHERE cpf = '999.888.777-66';

-- 11) Por isso apagamos primeiro os registros "filhos", do mais
--     dependente para o menos dependente, e por último o tutor.
DELETE FROM consulta   WHERE id_animal = (SELECT MAX(id_animal) FROM animal);
DELETE FROM prontuario WHERE numero_prontuario = 'PV-99999';
DELETE FROM animal     WHERE id_tutor = (SELECT id_tutor FROM tutor WHERE cpf = '999.888.777-66');
DELETE FROM tutor_telefone WHERE id_tutor = (SELECT id_tutor FROM tutor WHERE cpf = '999.888.777-66');
DELETE FROM tutor      WHERE cpf = '999.888.777-66';

-- 12) Conferindo: a consulta abaixo não deve retornar nenhuma linha
SELECT * FROM tutor WHERE cpf = '999.888.777-66';
