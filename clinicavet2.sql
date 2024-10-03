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

-- parte 2

use  clinica_veterinaria;

--  crie mais 3 tabelas que façam sentido para a aplicação

create table remedio(
id_remedio int primary key auto_increment,
nome varchar(100),
mg_ml varchar (50),
quantidade_estoque int
);
 
create table vacinas_animais(
id_vacina int primary key auto_increment,
id_animal int,
id_veterinario int, 
data_aplicacao date,
descrição text,
 
foreign key (id_animal) references pacientes(id_paciente),
foreign key (id_veterinario) references veterinarios(id_veterinario)
);
 
create table cliente (
id_cliente int primary key auto_increment,
nome varchar(100),
email varchar (50),
endereco varchar (200),
id_animal int,
id_consulta int,
 
foreign key (id_animal) references pacientes(id_paciente),
foreign key (id_consulta) references consultas(id_consulta)
);

-- criando triggers


DELIMITER $$
create trigger verifica_estoque_remedio
after update on remedio
for each row
BEGIN
    IF new.quantidade_estoque < 0 THEN
        signal sqlstate '45000'
        set message_text = 'Quantidade de estoque não pode ser negativa';
    END IF;
END $$
DELIMITER ; 


DELIMITER $$ 
create trigger atualiza_consulta_cliente
after insert on consultas
for each row
begin 
	update cliente
    set id_consulta = new.id_consulta
    where id_animal = new.id_paciente;
end $$
delimiter ;

DELIMITER $$ 
create trigger checar_especialidade
before insert on veterinarios
for each row
begin
	if exists (select 1 from veterinarios where especialidade = new.especialidade) then
		signal sqlstate '45000'
		set message_text = 'Já existe um veterinário com essa especialidade';
	end if;
end $$
delimiter ;

-- atualizar o Log_consulta ao alterar o custo de uma consulta
DELIMITER $$ 
create trigger atualizar_log_consulta
after update on consultas
for each row
begin
	if old.custo != new.custo then
		insert into log_consulta (id_consulta, custo_antigo, custo_novo)
        values (old.id_consulta, old.custo, new.custo);
	end if;
end$$
delimiter ;

-- registrar uma nova consulta no cliente ao inserir uma consulta

DELIMITER $$ 
create trigger atualiza_consulta_cliente
after insert on consultas
for each row
begin
	update cliente
    set id_consulta = new.id_consulta
    where id_animal = new.id_paciente;
end $$
delimiter ;

-- CRIE 5 PROCEDURES

-- adicionar um novo cliente

DELIMITER $$
CREATE PROCEDURE adicionar_cliente(
    IN nome_cliente VARCHAR(100),
    IN email_cliente VARCHAR(100),
    IN endereco_cliente VARCHAR(200)
)
BEGIN
    INSERT INTO cliente (nome, email, endereco)
    VALUES (nome_cliente, email_cliente, endereco_cliente);
END $$
DELIMITER ;

-- atualizar o custo de uma consulta

DELIMITER $$
CREATE PROCEDURE atualizar_custo_consulta(
    IN consulta_id INT,
    IN novo_custo DECIMAL(10,2)
)
BEGIN
    UPDATE consultas
    SET custo = novo_custo
    WHERE id_consulta = consulta_id;
END $$
DELIMITER ;

-- listar todos os clientes

DELIMITER $$
CREATE PROCEDURE listar_clientes()
BEGIN
    SELECT * FROM cliente;
END $$
DELIMITER ;

-- listar todos os veterinarios

DELIMITER $$
CREATE PROCEDURE listar_veterinarios()
BEGIN
    SELECT * FROM veterinarios;
END $$
DELIMITER ;

-- registrar um novo veterinário

DELIMITER $$
CREATE PROCEDURE adicionar_veterinario(
    IN nome_veterinario VARCHAR(100),
    IN especialidade_veterinario VARCHAR(100)
)
BEGIN
    INSERT INTO veterinarios (nome, especialidade)
    VALUES (nome_veterinario, especialidade_veterinario);
END $$
DELIMITER ;

-- testes

CALL adicionar_cliente ('Carlos Souza', 'souza@email.com', 'Rua dsuahds, 123');

CALL listar_clientes();

CALL listar_veterinarios();

SELECT * FROM vacinas_animais;








