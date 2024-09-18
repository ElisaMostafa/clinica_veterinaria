create database clinica_veterinaria;
use  clinica_veterinaria;

create table pacientes(
id_paciente int primary key auto_increment,
nome varchar(100),
especie varchar (50),
idade int
);

create table veterinarios(
id_veterinario int primary key auto_increment,
nome varchar(100),
especialidade varchar (50)
);

create table consultas(
id_consulta int primary key auto_increment,
data_contulta date, 
custo decimal (10,2),
id_paciente int,
id_veterinario int,
FOREIGN KEY (id_paciente) REFERENCES pacientes(id_paciente),
FOREIGN KEY (id_veterinario) REFERENCES veterinarios(id_veterinario)
);

select * from consultas;

DELIMITER $$
CREATE PROCEDURE agendar_consulta (
in id_paciente int, 
in id_veterinario int, 
in data_consulta date, 
in custo decimal(10,2))
begin
insert into consultas (id_consulta, id_veterinario, data_consulta, custo) values
(id_consulta, id_veterinario, data_consulta, custo);
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE atualizar_paciente (
in p_id_paciente int, 
in novo_nome varchar(100), 
in nova_especie varchar(50), 
in nova_idade int
)
begin
update pacientes
set nome = novo_nome,
	especie = nova_especie,
    idade = nova_idade
where id_paciente = p_id_paciente;
END $$
DELIMITER ;

call atualizar_paciente(1, 'Zeca', 'cachorro', 12);
select * from pacientes;

DELIMITER $$
CREATE PROCEDURE remover_consulta (
in id_consulta int
)
begin
delete from Consultas
where id_consulta = id_consulta;
END $$
DELIMITER ;



DELIMITER $$
create function total_gasto_paciente (id_paciente int)
returns decimal (10,2)
DETERMINISTIC
BEGIN 
	declare valor_total decimal (10,2);
    
    SELECT (sum(custo), 0) INTO valor_total
    from Consultas
    where id_paciente = id_paciente;
    
    return valor_total;
END $$

DELIMITER ;


DELIMITER $$
CREATE TRIGGER verificar_idade_paciente
BEFORE INSERT ON pacientes
FOR EACH ROW
BEGIN
    IF NEW.idade <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Idade inválida. Deve ser um número positivo.';
    END IF;
END $$
DELIMITER ;

create table log_consultas(
id_log int primary key auto_increment,
id_consulta int,
custo_antigo decimal (10,2),
custo_novo decimal (10,2),
FOREIGN KEY (id_consulta) REFERENCES consultas(id_consulta)
);

DELIMITER $$
create trigger atualizar_custo_consulta
after update on Consultas
for each row
BEGIN
    IF OLD.custo <> NEW.custo THEN
        INSERT INTO Log_Consultas (id_consulta, custo_antigo, custo_novo)
        VALUES (OLD.id_consulta, OLD.custo, NEW.custo);
    END IF;
END $$
DELIMITER ;

describe consultas;
INSERT INTO Consultas (id_paciente, custo) VALUES (1, 250.00);
INSERT INTO Consultas (id_paciente, custo) VALUES (default, 300.00);

select * from consultas;
select * from log_consultas;
update consultas
set custo = 400.00
where id_consulta = 1;

INSERT INTO pacientes (idade) VALUES (7);




