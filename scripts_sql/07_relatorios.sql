-- Rede PetVida - Script 04: Relatórios
-- 10 consultas usando SELECT, JOIN, WHERE e ORDER BY.


-- R1. Quais consultas estão agendadas? (agenda da clínica)
SELECT c.data_hora,
       a.nome  AS animal,
       t.nome  AS tutor,
       v.nome  AS veterinario,
       c.motivo
FROM consulta c
JOIN animal a      ON a.id_animal = c.id_animal
JOIN tutor t       ON t.id_tutor = a.id_tutor
JOIN veterinario v ON v.id_veterinario = c.id_veterinario
WHERE c.status = 'Agendada'
ORDER BY c.data_hora;


-- R2. Histórico de consultas do animal com prontuário PV-00010
SELECT p.numero_prontuario,
       a.nome AS animal,
       c.data_hora,
       c.tipo,
       c.diagnostico,
       v.nome AS veterinario
FROM prontuario p
JOIN animal a      ON a.id_animal = p.id_animal
JOIN consulta c    ON c.id_animal = a.id_animal
JOIN veterinario v ON v.id_veterinario = c.id_veterinario
WHERE p.numero_prontuario = 'PV-00010'
ORDER BY c.data_hora;


-- R3. Alerta: animais que receberam um medicamento ao qual são alérgicos
SELECT a.nome           AS animal,
       p.alergias,
       m.nome_comercial AS medicamento_prescrito,
       c.data_hora
FROM prontuario p
JOIN animal a      ON a.id_animal = p.id_animal
JOIN consulta c    ON c.id_animal = a.id_animal
JOIN prescricao pr ON pr.id_consulta = c.id_consulta
JOIN medicamento m ON m.id_medicamento = pr.id_medicamento
WHERE m.principio_ativo = p.alergias
ORDER BY c.data_hora;


-- R4. Tutores de Curitiba e seus animais
SELECT t.nome AS tutor,
       t.bairro,
       a.nome AS animal,
       a.especie,
       a.raca
FROM tutor t
JOIN animal a ON a.id_tutor = t.id_tutor
WHERE t.cidade = 'Curitiba'
ORDER BY t.nome, a.nome;


-- R5. Telefones dos tutores de gatos (para campanha de vacinação felina)
SELECT t.nome  AS tutor,
       tf.numero,
       tf.tipo,
       a.nome  AS gato
FROM tutor t
JOIN tutor_telefone tf ON tf.id_tutor = t.id_tutor
JOIN animal a          ON a.id_tutor = t.id_tutor
WHERE a.especie = 'Gato'
ORDER BY t.nome;


-- R6. Cirurgias realizadas com valor acima de R$ 1.500,00
SELECT c.data_hora,
       a.nome AS animal,
       c.motivo,
       v.nome AS cirurgiao,
       c.valor_consulta
FROM consulta c
JOIN animal a      ON a.id_animal = c.id_animal
JOIN veterinario v ON v.id_veterinario = c.id_veterinario
WHERE c.tipo = 'Cirurgia'
  AND c.status = 'Realizada'
  AND c.valor_consulta > 1500
ORDER BY c.valor_consulta DESC;


-- R7. Quantas consultas realizadas cada veterinário fez (os 10 que mais atenderam)
SELECT v.nome,
       v.especialidade,
       COUNT(c.id_consulta) AS total_consultas
FROM veterinario v
JOIN consulta c ON c.id_veterinario = v.id_veterinario
WHERE c.status = 'Realizada'
GROUP BY v.id_veterinario, v.nome, v.especialidade
ORDER BY total_consultas DESC
LIMIT 10;


-- R8. Os 10 medicamentos mais prescritos
SELECT m.nome_comercial,
       m.fabricante,
       SUM(pr.quantidade) AS unidades_prescritas
FROM prescricao pr
JOIN medicamento m ON m.id_medicamento = pr.id_medicamento
JOIN consulta c    ON c.id_consulta = pr.id_consulta
WHERE c.status = 'Realizada'
GROUP BY m.nome_comercial, m.fabricante
ORDER BY unidades_prescritas DESC
LIMIT 10;


-- R9. Faturamento por cidade (valor total das consultas realizadas,
--     usando a view do atributo derivado valor_total)
SELECT t.cidade,
       COUNT(c.id_consulta) AS consultas,
       SUM(vt.valor_total)  AS faturamento
FROM consulta c
JOIN vw_consulta_valor_total vt ON vt.id_consulta = c.id_consulta
JOIN animal a                   ON a.id_animal = c.id_animal
JOIN tutor t                    ON t.id_tutor = a.id_tutor
WHERE c.status = 'Realizada'
GROUP BY t.cidade
ORDER BY faturamento DESC;


-- R10. Animais com 12 anos ou mais (usando a view do atributo derivado idade)
SELECT vi.nome AS animal,
       a.especie,
       vi.idade,
       t.nome  AS tutor
FROM vw_animal_idade vi
JOIN animal a ON a.id_animal = vi.id_animal
JOIN tutor t  ON t.id_tutor = a.id_tutor
WHERE vi.idade >= 12
ORDER BY vi.idade DESC, vi.nome;
