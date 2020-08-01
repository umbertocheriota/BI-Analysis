--������� ���������� ����������� ��������� �� ����� ��������� �� ������ ����������.	
-- ���������
-- �������� ROUND

select *, round(flight_qty::numeric / (sum(flight_qty) over ())::numeric * 100, 2) as "% from_ttl" --�������� ���� ������ � numeric ����� ������� �� ����� ����� -->
from ( --����� ���������� ������ �� ������� ���� �� �� ����� ���������� ������ (����� �� ����� �������) 
	select distinct --��������� ��� �������� ���������� ������
		a.aircraft_code,
		count(f.flight_id) over (partition by a.aircraft_code) as flight_qty --������� ������� ��� �������� ���������� ������ (flight_id), ������������� �� ���� �� 
	from aircrafts a
	join flights f on f.aircraft_code = a.aircraft_code 
	order by flight_qty desc
	) as qty --�������� ������� �� ���������� qty 

