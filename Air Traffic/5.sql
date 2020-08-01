/*
������� ��������� ����� ��� ������� �����, �� % ��������� � ������ ���������� ���� � ��������.
�������� ������� � ������������� ������ - ��������� ���������� ���������� ���������� �� ��������� �� ����. 
�.�. � ���� ������� ������ ���������� ����� - ������� ������� ��� �������� �� ������� ��������� �� ���� ��� ����� ������ ������ �� ����������� ����	
- ������� �������
- ���������
*/

--5.1 ������� ��������� ����� ��� ������� �����
with vacant_seats as ( --������ CTE "��������� ������"
	select f.flight_id, s.seat_no as vacant_seat --���������� ��� ������ �� ������ flight_id
	from flights f
	join aircrafts a on a.aircraft_code = f.aircraft_code 
	join seats s on s.aircraft_code = a.aircraft_code 
		except --������� �� ������ �� ������, �� ������� ���� ������ ���������� ������ (�.�. �������� ������ �� ���� � ����� ��� �����)
	select bp.flight_id, bp.seat_no
	from boarding_passes bp 
	order by flight_id 
)
select f.flight_no, vacant_seats.flight_id, vacant_seats.vacant_seat
from vacant_seats 
join flights f on f.flight_id = vacant_seats.flight_id


--5.2 �� % ��������� � ������ ���������� ���� � ��������.
select 
	f.flight_no,
	occupied_seats.flight_id, 
	count(occupied_seats.flight_id) as occupied_seat, --���������� ���������� ������� ������
	f.aircraft_code,
	seat_capacity.ac_seat_capacity, --���������� ����� ���������� ���� �� �����
	round((count(occupied_seats.flight_id::numeric) / seat_capacity.ac_seat_capacity::numeric) * 100, 1) as "load_factor, %" --���������� load factor. % �������� �����
from (select bp.flight_id, bp.seat_no from boarding_passes bp order by flight_id) as occupied_seats --��������� ��� ������� ������� ������ (��������� �� ���� ����������)
join flights f on f.flight_id = occupied_seats.flight_id
join (select aircraft_code, count(row_number) as ac_seat_capacity --��������� ��� ������� ������ ���������� ���� �� ������ ���� ��
	from (select s.aircraft_code, s.seat_no, row_number() over (partition by s.aircraft_code) --��������� � ������� �������� ��� ��������� ���� ������ �� �����
		from seats s) as seat_capacity
	group by aircraft_code) as seat_capacity on seat_capacity.aircraft_code = f.aircraft_code --��������� ��������� �� ���� ��
group by occupied_seats.flight_id, f.aircraft_code, seat_capacity.ac_seat_capacity, f.flight_no 


--5.3 �������� ������� � ������������� ������ - ��������� ���������� ���������� ���������� �� ��������� �� ����. 
with ttl as ( --������ CTE, ����� �� ���� �������� ����� ������� ������, �.�. ������ ������������ ������� ������� � ������ ������� ������� 
select 
	f.flight_no,
	occupied_seats.flight_id, 
	f.departure_airport,
	count(occupied_seats.flight_id) as pax, --���������� ���������� ������� ������
	f.aircraft_code,
	seat_capacity.seat_capacity, --���������� ����� ���������� ���� �� �����
	round((count(occupied_seats.flight_id::numeric) / seat_capacity.seat_capacity::numeric) * 100, 1) as "load_factor, %", --���������� load factor. % �������� ����� -->
	f.actual_departure --�������� ��� ������ � numeric, ����� �������� �� ����� �����, ���������� round ��� ���������� � ��������� 1 ���� ����� �������
from (select bp.flight_id, bp.seat_no from boarding_passes bp order by flight_id) as occupied_seats --��������� ��� ������� ������� ������ (��������� �� ���� ����������)
join flights f on f.flight_id = occupied_seats.flight_id 
join (select aircraft_code, count(row_number) as seat_capacity --��������� ��� ������� ������ ���������� ���� �� ������ ���� ��
	from (select s.aircraft_code,	s.seat_no,	row_number() over (partition by s.aircraft_code) --��������� � ������� �������� ��� ��������� ���� ������ �� �����
		from seats s) as seat_capacity
	group by aircraft_code) as seat_capacity on seat_capacity.aircraft_code = f.aircraft_code --��������� ��������� �� ���� ��
where f.actual_departure is not null --��������������� NULL �������� actual_departure, �.�. �� �����, ������� ��� �� ��������
group by occupied_seats.flight_id, f.aircraft_code, seat_capacity.seat_capacity, f.flight_no, f.departure_airport, f.actual_departure
)
select *, sum(ttl.pax) over (partition by ttl.actual_departure::date, ttl.departure_airport order by ttl.actual_departure, ttl.departure_airport) as pax_per_day
from ttl --�������� ��� �� �� ������� + ����� �� ������� pax, �.�. ����� ����������, "������������" ������� �������� �� ���� ����������� � ��������� ������ -->
--���� ����������� �������� � ���� ������ date, �.�. �� ��������� ��� timestamp � ������ ����� ����� ����� ��������� ��� ����� ������ ��� "�����������"
