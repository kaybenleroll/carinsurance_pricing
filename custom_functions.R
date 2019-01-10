
create_assessment_simulator <- function(claimrate_model_glm
                                       ,claimsize_model_glm
                                       ,largeloss_threshold
                                       ,largeloss_rate
                                       ,largeloss_sf) {

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

        mc_iteration <- function() {

            ### simulating ordinary claims
            claim_count <- sapply(claim_rate, function(x) rpois(1, x))

            if(simulate_claim_size) {
                claim_total <- mapply(function(count, shape, rate) {
                    if(count == 0) {
                        total_claims <- 0
                    } else {
                        claim_amount <- rgamma(count
                                              ,shape = claim_gamma_shape
                                              ,rate = claim_gamma_rate)

                        total_claims <- sum(claim_amount)
                    }

                    return(total_claims)
                }, claim_count, claim_gamma_shape, claim_gamma_rate)
            } else {
                claim_total <- claim_count * claim_size
            }

            largeloss_count  <- rpois(n_policies, largeloss_rate)
            largeloss_amount <- rpldis(sum(largeloss_count)
                                      ,xmin = largeloss_threshold
                                      ,alpha = largeloss_sf)

            return(c(bau_claims   = sum(claim_total)
                    ,large_claims = sum(largeloss_amount)
                    ,total_claims = sum(claim_total) + sum(largeloss_amount)
                    ))
        }

        return(mc_iteration)
    }

    return(assessment_simulator)
}


sim_glm <- function(object, n.sims=100) {
    object.class <- class(object)[[1]]
    summ <- summary (object, correlation=TRUE, dispersion = object$dispersion)
    coef <- summ$coef[,1:2,drop=FALSE]
    dimnames(coef)[[2]] <- c("coef.est","coef.sd")
    beta.hat <- coef[,1,drop=FALSE]
    sd.beta <- coef[,2,drop=FALSE]
    corr.beta <- summ$corr
    n <- summ$df[1] + summ$df[2]
    k <- summ$df[1]
    V.beta <- corr.beta * array(sd.beta,c(k,k)) * t(array(sd.beta,c(k,k)))
    beta <- array (NA, c(n.sims,k))
    dimnames(beta) <- list (NULL, dimnames(beta.hat)[[1]])
    for (s in 1:n.sims){
        beta[s,] <- MASS::mvrnorm (1, beta.hat, V.beta)
    }
    # Added by Masanao
    beta2 <- array (0, c(n.sims,length(coefficients(object))))
    dimnames(beta2) <- list (NULL, names(coefficients(object)))
    beta2[,dimnames(beta2)[[2]]%in%dimnames(beta)[[2]]] <- beta
    # Added by Masanao
    sigma <- rep (sqrt(summ$dispersion), n.sims)

    ans <- new("sim",
               coef = beta2,
               sigma = sigma)
    return(ans)
}

