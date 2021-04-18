SELECT MIN(chn.name) AS uncredited_voiced_character,
       MIN(t.title) AS russian_movie
FROM char_name AS chn,
     cast_info AS ci,
     company_name AS cn,
     company_type AS ct,
     movie_companies AS mc,
     role_type AS rt,
     title AS t
WHERE ci.note LIKE '%(voice)%'
  AND ci.note LIKE '%(uncredited)%'
  AND cn.country_code = '[ru]'
  AND rt.role = 'actor'
  AND t.production_year > 2005
  AND t.id = mc.movie_id
  AND t.id = ci.movie_id
  AND ci.movie_id = mc.movie_id
  AND chn.id = ci.person_role_id
  AND rt.id = ci.role_id
  AND cn.id = mc.company_id
  AND ct.id = mc.company_type_id;


Finalize Aggregate  (cost=46752.12..46752.13 rows=1 width=64)
  ->  Gather  (cost=46751.90..46752.11 rows=2 width=64)
        Workers Planned: 2
        ->  Partial Aggregate  (cost=45751.90..45751.91 rows=1 width=64)
              ->  Nested Loop  (cost=4736.00..45751.89 rows=2 width=33)
                    ->  Nested Loop  (cost=4735.87..45751.59 rows=2 width=37)
                          ->  Hash Join  (cost=4735.44..45725.12 rows=5 width=25)
                                Hash Cond: (ci.role_id = rt.id)
                                ->  Nested Loop  (cost=4734.28..45723.75 rows=55 width=29)
                                      Join Filter: (t.id = ci.movie_id)
                                      ->  Nested Loop  (cost=4733.71..40613.13 rows=2591 width=29)
                                            ->  Parallel Hash Join  (cost=4733.28..37248.44 rows=6523 width=8)
                                                  Hash Cond: (mc.company_id = cn.id)
                                                  ->  Parallel Seq Scan on movie_companies mc  (cost=0.00..29661.37 rows=1087137 width=12)
                                                  ->  Parallel Hash  (cost=4722.92..4722.92 rows=829 width=4)
                                                        ->  Parallel Seq Scan on company_name cn  (cost=0.00..4722.92 rows=829 width=4)
                                                              Filter: ((country_code)::text = '[ru]'::text)
                                            ->  Index Scan using title_pkey on title t  (cost=0.43..0.52 rows=1 width=21)
                                                  Index Cond: (id = mc.movie_id)
                                                  Filter: (production_year > 2005)
                                      ->  Index Scan using movie_id_cast_info on cast_info ci  (cost=0.56..1.96 rows=1 width=12)
                                            Index Cond: (movie_id = mc.movie_id)
                                            Filter: (((note)::text ~~ '%(voice)%'::text) AND ((note)::text ~~ '%(uncredited)%'::text))
                                ->  Hash  (cost=1.15..1.15 rows=1 width=4)
                                      ->  Seq Scan on role_type rt  (cost=0.00..1.15 rows=1 width=4)
                                            Filter: ((role)::text = 'actor'::text)
                          ->  Index Scan using char_name_pkey on char_name chn  (cost=0.43..5.29 rows=1 width=20)
                                Index Cond: (id = ci.person_role_id)
                    ->  Index Only Scan using company_type_pkey on company_type ct  (cost=0.13..0.15 rows=1 width=4)
                          Index Cond: (id = mc.company_type_id)
