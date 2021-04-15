SELECT MIN(mc.note) AS production_note,
       MIN(t.title) AS movie_title,
       MIN(t.production_year) AS movie_year
FROM company_type AS ct,
     info_type AS it,
     movie_companies AS mc,
     movie_info_idx AS mi_idx,
     title AS t
WHERE ct.kind = 'production companies'
  AND it.info = 'bottom 10 rank'
  AND mc.note NOT LIKE '%(as Metro-Goldwyn-Mayer Pictures)%'
  AND t.production_year > 2000
  AND ct.id = mc.company_type_id
  AND t.id = mc.movie_id
  AND t.id = mi_idx.movie_id
  AND mc.movie_id = mi_idx.movie_id
  AND it.id = mi_idx.info_type_id;



Finalize Aggregate  (cost=20982.06..20982.07 rows=1 width=68)
  ->  Gather  (cost=20981.84..20982.05 rows=2 width=68)
        Workers Planned: 2
        ->  Partial Aggregate  (cost=19981.84..19981.85 rows=1 width=68)
              ->  Hash Join  (cost=4.35..19968.71 rows=1750 width=45)
                    Hash Cond: (mc.company_type_id = ct.id)
                    ->  Nested Loop  (cost=3.29..19929.79 rows=7003 width=49)
                          ->  Nested Loop  (cost=2.86..18176.93 rows=2757 width=29)
                                ->  Hash Join  (cost=2.43..15253.60 rows=5089 width=4)
                                      Hash Cond: (mi_idx.info_type_id = it.id)
                                      ->  Parallel Seq Scan on movie_info_idx mi_idx  (cost=0.00..13685.15 rows=575015 width=8)
                                      ->  Hash  (cost=2.41..2.41 rows=1 width=4)
                                            ->  Seq Scan on info_type it  (cost=0.00..2.41 rows=1 width=4)
                                                  Filter: ((info)::text = 'bottom 10 rank'::text)
                                ->  Index Scan using title_pkey on title t  (cost=0.43..0.57 rows=1 width=25)
                                      Index Cond: (id = mi_idx.movie_id)
                                      Filter: (production_year > 2000)
                          ->  Index Scan using movie_id_movie_companies on movie_companies mc  (cost=0.43..0.61 rows=3 width=32)
                                Index Cond: (movie_id = t.id)
                                Filter: ((note)::text !~~ '%(as Metro-Goldwyn-Mayer Pictures)%'::text)
                    ->  Hash  (cost=1.05..1.05 rows=1 width=4)
                          ->  Seq Scan on company_type ct  (cost=0.00..1.05 rows=1 width=4)
                                Filter: ((kind)::text = 'production companies'::text)
