-- Dados
--
-- Em vez de escrever milhares de INSERTs à mão, cada tabela é
-- populada com INSERT ... SELECT usando generate_series(1, N),
-- que gera os números de 1 até N (a variável n).



-- 1) TUTOR: 500 registros
INSERT INTO tutor (nome, cpf, email, data_nascimento, logradouro, numero,
                   bairro, cidade, uf, cep, data_cadastro)
SELECT
    -- nome: primeiro nome + dois sobrenomes
    (ARRAY['Ana','Bruno','Carla','Daniel','Eduardo','Fernanda','Gabriel','Helena','Igor','Juliana',
           'Lucas','Mariana','Nicolas','Olivia','Pedro','Rafaela','Samuel','Tatiana','Vitor','Yasmin'])[n % 20 + 1]
    || ' ' ||
    (ARRAY['Silva','Santos','Oliveira','Souza','Lima','Pereira','Costa','Ribeiro','Martins','Carvalho',
           'Almeida','Lopes','Rocha','Dias','Moreira','Nunes','Mendes','Freitas','Cardoso','Ramos'])[(n / 20) % 20 + 1]
    || ' ' ||
    (ARRAY['Silva','Santos','Oliveira','Souza','Lima','Pereira','Costa','Ribeiro','Martins','Carvalho',
           'Almeida','Lopes','Rocha','Dias','Moreira','Nunes','Mendes','Freitas','Cardoso','Ramos'])[(n * 7) % 20 + 1],
    -- CPF fictício e único (usa o número n)
    '100.200.' || LPAD(n::TEXT, 3, '0') || '-' || LPAD((n % 97)::TEXT, 2, '0'),
    -- e-mail único
    'tutor' || n || '@email.com',
    -- nascimento entre 1960 e 2001 (todos maiores de idade)
    DATE '1960-01-01' + (n * 37) % 15000,
    (ARRAY['Rua das Flores','Avenida Brasil','Rua São José','Rua XV de Novembro','Avenida Paulista',
           'Rua Tiradentes','Rua da Paz','Rua Santos Dumont'])[(n / 8) % 8 + 1],
    ((n * 7) % 900 + 1)::TEXT,
    (ARRAY['Centro','Jardim América','Vila Nova','Boa Vista','Santa Cruz'])[n % 5 + 1],
    -- cidade, UF e CEP andam juntos (mesma posição nas três listas)
    (ARRAY['São Paulo','Rio de Janeiro','Belo Horizonte','Curitiba',
           'Porto Alegre','Salvador','Recife','Goiânia'])[n % 8 + 1],
    (ARRAY['SP','RJ','MG','PR','RS','BA','PE','GO'])[n % 8 + 1],
    (ARRAY['01','20','30','80','90','40','50','74'])[n % 8 + 1] || LPAD((n % 1000)::TEXT, 3, '0') || '-000',
    -- data de cadastro entre 2023 e 2025
    DATE '2023-01-01' + (n * 3) % 1000
FROM generate_series(1, 500) AS n;


-- -------------------------------------------------------------
-- 2) TUTOR_TELEFONE: 750 registros
--    Todo tutor tem um celular (500) e os tutores de número par
--    também têm um telefone residencial (250).
--    O DDD é o da cidade do tutor.
-- -------------------------------------------------------------
INSERT INTO tutor_telefone (id_tutor, numero, tipo)
SELECT
    t.id_tutor,
    '(' || (ARRAY['11','21','31','41','51','71','81','62'])[t.id_tutor % 8 + 1] || ') 9'
        || LPAD((1000 + t.id_tutor)::TEXT, 4, '0') || '-' || LPAD((t.id_tutor * 7 % 10000)::TEXT, 4, '0'),
    'Celular'
FROM tutor t;

INSERT INTO tutor_telefone (id_tutor, numero, tipo)
SELECT
    t.id_tutor,
    '(' || (ARRAY['11','21','31','41','51','71','81','62'])[t.id_tutor % 8 + 1] || ') 3'
        || LPAD((100 + t.id_tutor)::TEXT, 3, '0') || '-' || LPAD((t.id_tutor * 13 % 10000)::TEXT, 4, '0'),
    'Residencial'
FROM tutor t
WHERE t.id_tutor % 2 = 0;


-- -------------------------------------------------------------
-- 3) ANIMAL: 650 registros
--    Os animais 1 a 500 são um de cada tutor. Os animais 501 a 650
--    voltam para os tutores 1 a 150, que ficam com 2 animais cada.
--    A espécie segue o número: 6 em cada 10 são cães, 3 são gatos,
--    e o último alterna entre ave e coelho.
-- -------------------------------------------------------------
INSERT INTO animal (id_tutor, nome, especie, raca, sexo, data_nascimento, peso_kg)
SELECT
    (n - 1) % 500 + 1,
    (ARRAY['Thor','Luna','Mel','Bob','Nina','Max','Pipoca','Fred','Lola','Simba',
           'Bidu','Mia','Toby','Amora','Zeus','Pingo','Bolt','Frida','Chico','Paçoca',
           'Bento','Jade','Rex','Cacau','Fiona','Marley','Nala','Teddy','Kiwi','Mingau'])[n % 30 + 1],
    especie,
    CASE especie
        WHEN 'Cão'  THEN (ARRAY['SRD','Labrador','Poodle','Shih Tzu','Golden Retriever','Pinscher','Beagle'])[n % 7 + 1]
        WHEN 'Gato' THEN (ARRAY['SRD','Siamês','Persa','Maine Coon','Angorá'])[n % 5 + 1]
        WHEN 'Ave'  THEN (ARRAY['Calopsita','Periquito','Canário'])[n % 3 + 1]
        ELSE             (ARRAY['Mini Lop','Lionhead','Rex'])[n % 3 + 1]
    END,
    CASE WHEN n % 2 = 0 THEN 'M' ELSE 'F' END,
    -- nascimento entre 2010 e 2024
    DATE '2010-01-01' + (n * 23) % 5400,
    -- peso coerente com a espécie
    CASE especie
        WHEN 'Cão'  THEN (ARRAY[12, 30, 6, 6, 32, 4, 12])[n % 7 + 1] + (n % 3)   -- mesmo índice da raça
        WHEN 'Gato' THEN 2.5 + (n % 6)
        WHEN 'Ave'  THEN 0.1 + (n % 4) * 0.1
        ELSE             1.5 + (n % 3)
    END
FROM (
    SELECT n,
           CASE WHEN n % 10 < 6 THEN 'Cão'
                WHEN n % 10 < 9 THEN 'Gato'
                WHEN n % 20 = 9 THEN 'Ave'
                ELSE 'Coelho'
           END AS especie
    FROM generate_series(1, 650) AS n
) AS lista;


-- -------------------------------------------------------------
-- 4) PRONTUARIO: 650 registros (exatamente 1 por animal)
--    O prontuário é aberto no cadastro do tutor ou, se o animal
--    nasceu depois, 30 dias após o nascimento.
-- -------------------------------------------------------------
INSERT INTO prontuario (id_animal, numero_prontuario, data_abertura, castrado, alergias, observacoes)
SELECT
    a.id_animal,
    'PV-' || LPAD(a.id_animal::TEXT, 5, '0'),
    GREATEST(t.data_cadastro, a.data_nascimento + 30),
    a.id_animal % 3 <> 0,
    CASE WHEN a.id_animal % 10 = 0 THEN 'Dipirona'
         WHEN a.id_animal % 10 = 5 THEN 'Amoxicilina'
    END,
    CASE WHEN a.id_animal % 4 = 0 THEN 'Animal dócil.'
         WHEN a.id_animal % 4 = 1 THEN 'Ansioso no consultório.'
    END
FROM animal a
JOIN tutor t ON t.id_tutor = a.id_tutor;


-- -------------------------------------------------------------
-- 5) VETERINARIO: 500 registros
-- -------------------------------------------------------------
INSERT INTO veterinario (nome, crmv, especialidade, email, data_admissao, salario)
SELECT
    'Dr(a). ' ||
    (ARRAY['Alice','Bernardo','Camila','Diego','Elisa','Felipe','Giovana','Henrique','Isabela','João',
           'Larissa','Marcelo','Natália','Otávio','Paula','Renato','Sofia','Thiago','Vanessa','William'])[n % 20 + 1]
    || ' ' ||
    (ARRAY['Barros','Campos','Duarte','Fonseca','Guimarães','Leite','Macedo','Pacheco','Queiroz','Vasconcelos',
           'Batista','Correia','Farias','Nogueira','Teixeira','Andrade','Brito','Castro','Monteiro','Pinto'])[(n / 20) % 20 + 1],
    'CRMV-' || (ARRAY['SP','RJ','MG','PR','RS','BA','PE','GO'])[n % 8 + 1] || ' ' || (10000 + n),
    (ARRAY['Clínica Geral','Clínica Geral','Clínica Geral','Cirurgia','Dermatologia','Cardiologia'])[n % 6 + 1],
    'vet' || n || '@petvida.com.br',
    -- admissão entre 2012 e 2024
    DATE '2012-01-01' + (n * 11) % 4500,
    6000 + (n * 37) % 6000
FROM generate_series(1, 500) AS n;


-- -------------------------------------------------------------
-- 6) MEDICAMENTO: 500 registros
--    25 princípios ativos x 4 formas x 5 fabricantes = 500 combinações,
--    então cada nome comercial é único.
-- -------------------------------------------------------------
INSERT INTO medicamento (nome_comercial, principio_ativo, forma, fabricante, preco_unitario, estoque)
SELECT
    principio || ' ' || forma || ' (' || fabricante || ')',
    principio,
    forma,
    fabricante,
    -- preço base do princípio ativo + acréscimo pela forma
    ROUND(preco_base * (CASE forma WHEN 'Injetável' THEN 1.5 ELSE 1 END) + (n % 5), 2),
    (n * 37) % 300
FROM (
    SELECT n,
           (ARRAY['Amoxicilina','Dipirona','Meloxicam','Prednisolona','Cefalexina','Enrofloxacino','Metronidazol',
                  'Tramadol','Omeprazol','Ivermectina','Doxiciclina','Carprofeno','Furosemida','Gabapentina',
                  'Ondansetrona','Dexametasona','Cetoconazol','Fenbendazol','Praziquantel','Clindamicina',
                  'Enalapril','Ranitidina','Silimarina','Vitamina B12','Probiótico'])[(n - 1) % 25 + 1] AS principio,
           (ARRAY[12.50, 6.00, 18.90, 9.80, 15.40, 22.00, 11.30, 19.50, 8.70, 7.90, 16.20, 32.00, 10.40, 24.80,
                  27.50, 9.20, 14.60, 13.90, 21.00, 17.80, 12.10, 8.30, 19.90, 25.00, 29.90])[(n - 1) % 25 + 1] AS preco_base,
           (ARRAY['Comprimido','Cápsula','Injetável','Suspensão oral'])[(n - 1) / 25 % 4 + 1] AS forma,
           (ARRAY['VetPharma','BioAnimal','PetLab','Clinivet','Vida Animal'])[(n - 1) / 100 + 1] AS fabricante
    FROM generate_series(1, 500) AS n
) AS lista;


-- -------------------------------------------------------------
-- 7) CONSULTA: 1500 registros
--    Cada animal tem 2 ou 3 consultas. As datas vão de jan/2025
--    até dez/2026: o que já passou fica 'Realizada' (ou 'Cancelada'
--    a cada 15 consultas) e o que ainda vai acontecer fica 'Agendada'.
--    Diagnóstico só existe em consulta realizada.
-- -------------------------------------------------------------
INSERT INTO consulta (id_animal, id_veterinario, data_hora, tipo, motivo, diagnostico, valor_consulta, status)
SELECT
    (n - 1) % 650 + 1,
    (n - 1) % 500 + 1,
    data_hora,
    tipo,
    CASE tipo
        WHEN 'Rotina'     THEN (ARRAY['Check-up anual','Coceira intensa','Vômitos','Perda de apetite','Tosse'])[n % 5 + 1]
        WHEN 'Retorno'    THEN 'Retorno do tratamento'
        WHEN 'Vacinação'  THEN 'Vacina anual'
        WHEN 'Emergência' THEN (ARRAY['Atropelamento','Intoxicação','Convulsão'])[n % 3 + 1]
        ELSE                   (ARRAY['Castração','Remoção de nódulo','Limpeza de tártaro'])[n % 3 + 1]
    END,
    CASE WHEN status <> 'Realizada' THEN NULL
         WHEN tipo = 'Rotina'     THEN (ARRAY['Animal saudável','Dermatite alérgica','Gastroenterite','Gastrite','Traqueobronquite'])[n % 5 + 1]
         WHEN tipo = 'Retorno'    THEN 'Evolução satisfatória'
         WHEN tipo = 'Vacinação'  THEN 'Vacina aplicada'
         WHEN tipo = 'Emergência' THEN (ARRAY['Fratura','Intoxicação alimentar','Epilepsia'])[n % 3 + 1]
         ELSE                          'Cirurgia sem intercorrências'
    END,
    CASE tipo
        WHEN 'Rotina'     THEN 180.00
        WHEN 'Retorno'    THEN 80.00
        WHEN 'Vacinação'  THEN 120.00
        WHEN 'Emergência' THEN 350.00
        ELSE 1200.00 + (n % 10) * 100
    END,
    status
FROM (
    SELECT n, tipo, data_hora,
           CASE WHEN data_hora > CURRENT_DATE THEN 'Agendada'
                WHEN n % 15 = 0 THEN 'Cancelada'
                ELSE 'Realizada'
           END AS status
    FROM (
        SELECT n,
               -- dia entre 01/01/2025 e 01/12/2026, horário entre 8h e 17h
               TIMESTAMP '2025-01-01 08:00' + ((n % 700) * INTERVAL '1 day') + ((n % 10) * INTERVAL '1 hour') AS data_hora,
               CASE WHEN n % 10 < 5 THEN 'Rotina'
                    WHEN n % 10 < 7 THEN 'Retorno'
                    WHEN n % 10 = 7 THEN 'Vacinação'
                    WHEN n % 10 = 8 THEN 'Emergência'
                    ELSE 'Cirurgia'
               END AS tipo
        FROM generate_series(1, 1500) AS n
    ) AS datas
) AS lista;


-- -------------------------------------------------------------
-- 8) PRESCRICAO: um medicamento para cada consulta realizada
--    (menos vacinação) e um segundo medicamento nas consultas de
--    número par. O valor unitário é o preço do medicamento.
-- -------------------------------------------------------------
INSERT INTO prescricao (id_consulta, id_medicamento, quantidade, posologia, valor_unitario)
SELECT
    c.id_consulta,
    m.id_medicamento,
    c.id_consulta % 3 + 1,
    (ARRAY['1 dose a cada 12 horas por 7 dias','1 dose ao dia por 5 dias',
           '1 dose a cada 8 horas por 3 dias','Dose única'])[c.id_consulta % 4 + 1],
    m.preco_unitario
FROM consulta c
JOIN medicamento m ON m.id_medicamento = (c.id_consulta * 7) % 500 + 1
WHERE c.status = 'Realizada'
  AND c.tipo <> 'Vacinação';

INSERT INTO prescricao (id_consulta, id_medicamento, quantidade, posologia, valor_unitario)
SELECT
    c.id_consulta,
    m.id_medicamento,
    1,
    '1 dose ao dia por 10 dias',
    m.preco_unitario
FROM consulta c
JOIN medicamento m ON m.id_medicamento = (c.id_consulta * 7 + 250) % 500 + 1
WHERE c.status = 'Realizada'
  AND c.tipo <> 'Vacinação'
  AND c.id_consulta % 2 = 0;
