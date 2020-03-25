# Data Merging
WITH history_movie_grade_new AS (
    SELECT hmg.number,
           hmg.chinese_name,
           hmg.english_name,
           sum(hmg.score) Total,
           count(1) quantity
      FROM history_movie_grade hmg
     WHERE hmg.score >= 0 AND 
           hmg.score <> '-' AND 
           hmg.score <> ''
     GROUP BY hmg.number,
              hmg.chinese_name,
              hmg.english_name
),
director_score as(
SELECT hmgn.number,
       hmgn.chinese_name,
       hmgn.english_name,
       round(hmgn.Total / quantity,1) director_score
  FROM history_movie_grade_new hmgn
  left join movie_score_new msn
  on msn.number = hmgn.number),
movie_score_new AS (
    SELECT ms.Number,
           ms.Chinese_Name,
           ms.English_Name,
           ms.Genre,
           ms.Technology,
           ms.Release_Date,
           ms.Realease_Year,
           round(CASE WHEN ms.Realease_Year = '2017' THEN ms.Box_Office * 106.5 / 102.6 
                   WHEN ms.Realease_Year = '2018' THEN ms.Box_Office * 106.5 / 104.5 
                   ELSE ms.Box_Office END, 2) box_office_new,
           ms.Country,
           ms.baidu,
           ms.douban,
           ms.reviews
      FROM movie_score ms
),
act_score as(
select asa.number,
       sum(asa.actor_score) Total,
       count(1) quantity
 from actor_score asa where asa.actor_score>0 and asa.actor_score<>'无指数'
 group by asa.number
),
act_score_new as(
  SELECT asb.number,
         round(asb.Total/asb.quantity,2) actor_average_score,
         asb.Total
   from act_score asb
),
winning as(
    select number,
       total_jinji+total_baiyulan+total_feitian+total_jinxiang+total_jinma domestic,
       total_gana+total_weinisi+total_bolin international
   from (
select asa.number,
       sum(asa.jinji) total_jinji,
       sum(asa.baiyulan) total_baiyulan,
       sum(asa.feitian) total_feitian,
       sum(asa.jinxiang) total_jinxiang,
       sum(asa.jinma) total_jinma,
       sum(asa.gana) total_gana,
       sum(asa.weinisi) total_weinisi,
       sum(asa.bolin) total_bolin
     from actor_score asa 
     group by asa.number)
)


--select * from director_score ds where ds.director_score <>0
select msn.number,
       msn.chinese_name,
       msn.english_name,
       case when ds.director_score <>0 then ds.director_score  else msn.douban end director_score,
       msn.Genre,
       msn.Technology,
       msn.Release_Date,
       msn.Realease_Year,
       msn.box_office_new,
       msn.Country,
       msn.baidu,
       msn.douban,
       msn.reviews,
       asn.actor_average_score,
       asn.Total actor_total_score,
       w.domestic,
       w.international,
       case when msn.Technology like '%3D%' or msn.Technology like '%IMAX%' then 1 else 0 end "is_3d/IMAX"
 from movie_score_new msn 
    left join director_score ds
    on msn.number = ds.number
    left join act_score_new asn 
    on asn.number = msn.number
    left join winning w 
    on w.number=msn.number