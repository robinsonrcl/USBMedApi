select componente,position, coordenadas from hallazgo order by 1 where position like '%aca%';
select * from revisor;
SELECT * from foto;
select * from componente;
select * from corriente;

truncate hallazgo  cascade;
truncate contrato cascade;
truncate corriente cascade;
truncate foto cascade;
