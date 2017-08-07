
# create_assessment_simulator <- function(claimrate_model_glm
#                                        ,claimsize_model_glm
#                                        ,largeloss_threshold
#                                        ,largeloss_rate
#                                        ,largeloss_sf) {
# 
#     assessment_simulator <- function(policydata_dt
#                                     ,simulate_claim_size = TRUE) {
# 
#         n_policies <- nrow(policydata_dt)
# 
#         claim_rate <- predict(claimrate_model_glm
#                              ,newdata = policydata_dt
#                              ,type = 'response')
# 
#         claim_size <- predict(claimsize_model_glm
#                              ,newdata = policydata_dt
#                              ,type = 'response')
# 
#         claim_gamma_shape <- MASS::gamma.shape(claimsize_model_glm)$alpha
#         claim_gamma_rate  <- claim_gamma_shape / claim_size
# 
#         mc_iteration <- function() {
# 
#             ### simulating ordinary claims
#             claim_count <- sapply(claim_rate, function(x) rpois(1, x))
# 
#             if(simulate_claim_size) {
#                 claim_total <- mapply(function(count, shape, rate) {
#                     if(count == 0) {
#                         total_claims <- 0
#                     } else {
#                         claim_amount <- rgamma(count
#                                               ,shape = claim_gamma_shape
#                                               ,rate = claim_gamma_rate)
# 
#                         total_claims <- sum(claim_amount)
#                     }
# 
#                     return(total_claims)
#                 }, claim_count, claim_gamma_shape, claim_gamma_rate)
#             } else {
#                 claim_total <- claim_count * claim_size
#             }
# 
#             largeloss_count  <- rpois(n_policies, largeloss_rate)
#             largeloss_amount <- rpldis(sum(largeloss_count)
#                                       ,xmin = largeloss_threshold
#                                       ,alpha = largeloss_sf)
# 
#             return(c(bau_claims   = sum(claim_total)
#                     ,large_claims = sum(largeloss_amount)
#                     ,total_claims = sum(claim_total) + sum(largeloss_amount)
#                     ))
#         }
# 
#         return(mc_iteration)
#     }
# 
#     return(assessment_simulator)
# }



create_assessment_simulator <- function(claimrate_model_glm
                                        ,claimsize_model_glm
                                        ,largeloss_threshold
                                        ,largeloss_rate
                                        ,largeloss_sf
                                        ,n_sim) {
    
    assessment_simulator <- function(policydata_dt
                                     ,simulate_claim_size = TRUE) {
        
        n_policies <- nrow(policydata_dt)
        
        claim_rate <- predict(claimrate_model_glm
                              ,newdata = policydata_dt
                              ,type = 'response')
        
        claim_size <- predict(claimsize_model_glm
                              ,newdata = policydata_dt
                              ,type = 'response')
        
        claim_gamma_shape <- MASS::gamma.shape(claimsize_model_glm)$alpha
        claim_gamma_rate  <- claim_gamma_shape / claim_size
        
        mc_sim <- function() {
            
            ### simulating ordinary claims
            claim_count  <- matrix(rpois(n_policies * n_sim, claim_rate), nrow = n_policies)
            
            claim_total <- matrix(0, nrow = n_policies, ncol = n_sim)
            
            if(simulate_claim_size) {
                for (i in 1:max(claim_count)) {
                    claim_amount <- matrix(rgamma(n_policies * n_sim
                                                  ,shape = claim_gamma_shape
                                                  ,rate = claim_gamma_rate)
                                           ,nrow = n_policies)
                    
                    claim_total <- claim_total + (claim_count >= i) * claim_amount
                }
                
            } else {
                claim_total <- claim_count * claim_size
            }
            
            largeloss_count  <- matrix(rpois(n_policies * n_sim, largeloss_rate), nrow = n_policies)
            
            largeloss_amount <- sapply(colSums(largeloss_count), function(iter) sum(rpldis(iter
                                                                                           ,xmin = largeloss_threshold
                                                                                           ,alpha = largeloss_sf)))

            return(data.frame(bau_claims   = colSums(claim_total)
                              ,large_claims = largeloss_amount
                              ,total_claims = colSums(claim_total) + largeloss_amount
            ))
        }
        
        return(mc_sim)
    }
    
    return(assessment_simulator)
}
