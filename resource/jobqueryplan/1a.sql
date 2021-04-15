SELECT MIN(mc.note) AS production_note,
       MIN(t.title) AS movie_title,
       MIN(t.production_year) AS movie_year
FROM company_type AS ct,
     info_type AS it,
     movie_companies AS mc,
     movie_info_idx AS mi_idx,
     title AS t
WHERE ct.kind = 'production companies'
  AND it.info = 'top 250 rank'
  AND mc.note NOT LIKE '%(as Metro-Goldwyn-Mayer Pictures)%'
  AND (mc.note LIKE '%(co-production)%'
       OR mc.note LIKE '%(presents)%')
  AND ct.id = mc.company_type_id
  AND t.id = mc.movie_id
  AND t.id = mi_idx.movie_id
  AND mc.movie_id = mi_idx.movie_id
  AND it.id = mi_idx.info_type_id;



Finalize Aggregate  (cost=19533.84..19533.85 rows=1 width=68)
  ->  Gather  (cost=19533.61..19533.82 rows=2 width=68)
        Workers Planned: 2
        ->  Partial Aggregate  (cost=18533.61..18533.62 rows=1 width=68)
              ->  Nested Loop  (cost=4.35..18533.36 rows=34 width=45)
                    Join Filter: (mc.movie_id = t.id)
                    ->  Hash Join  (cost=3.92..18513.48 rows=34 width=32)
                          Hash Cond: (mc.company_type_id = ct.id)
                          ->  Nested Loop  (cost=2.86..18511.69 rows=136 width=36)
                                ->  Hash Join  (cost=2.43..15253.60 rows=5089 width=4)
                                      Hash Cond: (mi_idx.info_type_id = it.id)
                                      ->  Parallel Seq Scan on movie_info_idx mi_idx  (cost=0.00..13685.15 rows=575015 width=8)
                                      ->  Hash  (cost=2.41..2.41 rows=1 width=4)
                                            ->  Seq Scan on info_type it  (cost=0.00..2.41 rows=1 width=4)
                                                  Filter: ((info)::text = 'top 250 rank'::text)
                                ->  Index Scan using movie_id_movie_companies on movie_companies mc  (cost=0.43..0.63 rows=1 width=32)
                                      Index Cond: (movie_id = mi_idx.movie_id)
                                      Filter: (((note)::text !~~ '%(as Metro-Goldwyn-Mayer Pictures)%'::text) AND (((note)::text ~~ '%(co-production)%'::text) OR ((note)::text ~~ '%(presents)%'::text)))
                          ->  Hash  (cost=1.05..1.05 rows=1 width=4)
                                ->  Seq Scan on company_type ct  (cost=0.00..1.05 rows=1 width=4)
                                      Filter: ((kind)::text = 'production companies'::text)
                    ->  Index Scan using title_pkey on title t  (cost=0.43..0.57 rows=1 width=25)
                          Index Cond: (id = mi_idx.movie_id)
