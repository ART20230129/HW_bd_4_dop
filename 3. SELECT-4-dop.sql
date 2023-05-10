--количество исполнителей в каждом жанре
SELECT name_genre, count(executor_id) FROM music_genre mg
LEFT JOIN performer_different_genres pdg ON mg.genre_id = pdg.genre_id 
GROUP BY mg.name_genre 
ORDER BY count(executor_id);

--количество треков, вошедших в альбомы 2019–2020 годов
SELECT count(track_id) FROM track_list tl  
JOIN album_list al ON tl.album_id = al.album_id 
WHERE year_publiction BETWEEN 2019 AND 2020;

--cредняя продолжительность треков по каждому альбому
SELECT name_album, avg(track_duration) FROM album_list al  
JOIN track_list tl ON al.album_id = tl.album_id 
GROUP BY name_album;

--все исполнители, которые не выпустили альбомы в 2020 году
SELECT name_executor FROM music_executor me 
WHERE name_executor NOT IN ( /* Где имя исполнителя не входит в вложенную выборку */
    SELECT name_executor FROM music_executor me
    JOIN executor_ft_executor efe ON me.executor_id = efe.executor_id
    JOIN album_list al ON efe.album_id = al.album_id 
    WHERE year_publiction = 2020
);


--названия сборников, в которых присутствует конкретный исполнитель (выберите его сами- ABBA)
SELECT c.name_collection FROM collection_track c 
JOIN track_collection tc ON c.collection_id = tc.collection_id 
JOIN track_list tl ON tc.track_id = tl.track_id 
JOIN album_list al ON tl.album_id = al.album_id 
JOIN executor_ft_executor efe ON al.album_id = efe.album_id  
JOIN music_executor me ON efe.executor_id = me.executor_id 
WHERE me.name_executor = 'ABBA'; 

--Названия альбомов, в которых присутствуют исполнители более чем одного жанра
SELECT DISTINCT name_album FROM album_list al 
JOIN executor_ft_executor efe ON al.album_id = efe.album_id 
JOIN music_executor me ON efe.executor_id = me.executor_id 
JOIN performer_different_genres pdg ON me.executor_id = pdg.executor_id 
GROUP BY name_album, pdg.executor_id  
HAVING COUNT(genre_id) > 1; 

--Наименования треков, которые не входят в сборники
SELECT name_track FROM track_list tl 
FULL OUTER JOIN track_collection tc ON tl.track_id = tc.track_id 
LEFT JOIN collection_track ct ON tc.collection_id = ct.collection_id 
WHERE ct.collection_id IS NULL;

--Исполнитель или исполнители, написавшие самый короткий по продолжительности трек
SELECT me.name_executor, tl.track_duration FROM music_executor me 
JOIN executor_ft_executor efe ON me.executor_id = efe.executor_id 
JOIN album_list al ON efe.album_id = al.album_id 
JOIN track_list tl ON al.album_id = tl.album_id 
WHERE tl.track_duration = (SELECT min(track_duration) FROM track_list);

--Названия альбомов, содержащих наименьшее количество треков

SELECT al.name_album FROM album_list al  /* Названия альбомов */
JOIN track_list tl ON al.album_id = tl.album_id /* Объединяем альбомы и треки */
GROUP BY al.album_id /* Группируем по айди альбомов */
HAVING COUNT(tl.name_track) = ( /* Где количество треков равно вложенному запросу, в котором получаем наименьшее количество треков в одном альбоме */
    SELECT COUNT(track_id) FROM track_list tl2  /* Получаем поличество айди треков из таблицы треков*/
    GROUP BY album_id /* Группируем по айди альбомов */
    ORDER BY 1 /* Сортируем по первому столбцу */
    LIMIT 1 /* Получаем первую запись */
);