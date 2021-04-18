SELECT MIN(chn.name) AS character,
       MIN(t.title) AS russian_mov_with_actor_producer
FROM char_name AS chn,
     cast_info AS ci,
     company_name AS cn,
     company_type AS ct,
     movie_companies AS mc,
     role_type AS rt,
     title AS t
WHERE ci.note LIKE '%(producer)%'
  AND cn.country_code = '[ru]'
  AND rt.role = 'actor'
  AND t.production_year > 2010
  AND t.id = mc.movie_id
  AND t.id = ci.movie_id
  AND ci.movie_id = mc.movie_id
  AND chn.id = ci.person_role_id
  AND rt.id = ci.role_id
  AND cn.id = mc.company_id
  AND ct.id = mc.company_type_id;


Finalize Aggregate  (cost=43609.16..43609.17 rows=1 width=64)
  ->  Gather  (cost=43608.94..43609.15 rows=2 width=64)
        Workers Planned: 2
        ->  Partial Aggregate  (cost=42608.94..42608.95 rows=1 width=64)
              ->  Hash Join  (cost=4736.96..42608.63 rows=61 width=33)
                    Hash Cond: (mc.company_type_id = ct.id)
                    ->  Nested Loop  (cost=4735.87..42607.22 rows=61 width=37)
                          ->  Hash Join  (cost=4735.44..42534.67 rows=126 width=25)
                                Hash Cond: (ci.role_id = rt.id)
                                ->  Nested Loop  (cost=4734.28..42528.13 rows=1513 width=29)
                                      Join Filter: (t.id = ci.movie_id)
                                      ->  Nested Loop  (cost=4733.71..40613.13 rows=1020 width=29)
                                            ->  Parallel Hash Join  (cost=4733.28..37248.44 rows=6523 width=8)
                                                  Hash Cond: (mc.company_id = cn.id)
                                                  ->  Parallel Seq Scan on movie_companies mc  (cost=0.00..29661.37 rows=1087137 width=12)
                                                  ->  Parallel Hash  (cost=4722.92..4722.92 rows=829 width=4)
                                                        ->  Parallel Seq Scan on company_name cn  (cost=0.00..4722.92 rows=829 width=4)
                                                              Filter: ((country_code)::text = '[ru]'::text)
                                            ->  Index Scan using title_pkey on title t  (cost=0.43..0.52 rows=1 width=21)
                                                  Index Cond: (id = mc.movie_id)
                                                  Filter: (production_year > 2010)
                                      ->  Index Scan using movie_id_cast_info on cast_info ci  (cost=0.56..1.86 rows=1 width=12)
                                            Index Cond: (movie_id = mc.movie_id)
                                            Filter: ((note)::text ~~ '%(producer)%'::text)
                                ->  Hash  (cost=1.15..1.15 rows=1 width=4)
                                      ->  Seq Scan on role_type rt  (cost=0.00..1.15 rows=1 width=4)
                                            Filter: ((role)::text = 'actor'::text)
                          ->  Index Scan using char_name_pkey on char_name chn  (cost=0.43..0.58 rows=1 width=20)
                                Index Cond: (id = ci.person_role_id)
                    ->  Hash  (cost=1.04..1.04 rows=4 width=4)
                          ->  Seq Scan on company_type ct  (cost=0.00..1.04 rows=4 width=4)
