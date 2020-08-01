--���� �� ������, � ������� �����  ��������� ������ - ������� �������, ��� ������-������� � ������ ��������?	
-- CTE

select distinct comparison.flight_id, f.departure_airport, f.arrival_airport, comparison.business, comparison.bc_amount, comparison.economy, comparison.yc_amount
from (
	with business as ( --CTE ������������ ������ ������ ������-������
		select distinct tf.flight_id, tf.fare_conditions, tf.amount from ticket_flights tf
		where tf.fare_conditions = 'Business' --������� ��� ������ ������ �������
	)
	select business.flight_id, business.fare_conditions business, business.amount bc_amount, economy.fare_conditions economy, economy.amount yc_amount
	from business 
	join (select * from ticket_flights tf where tf.fare_conditions = 'Economy') as economy on economy.flight_id = business.flight_id --���������� � �������� ��� ������-������
) comparison --������������� �������������, �������� ��� comparison
join flights f on f.flight_id = comparison.flight_id --������������ � ������������ ������� flights
where bc_amount < yc_amount --��� ���� �� ������-����� ������, ��� � ������� �� ��� �� ����� 

--�����: ���