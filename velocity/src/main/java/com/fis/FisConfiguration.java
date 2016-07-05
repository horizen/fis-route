package com.fis;


import com.baidu.fis.velocity.spring.FisBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;


/**
 * Created by Administrator on 2015/3/6.
 */
@Configuration
public class FisConfiguration {
//    @Value("${velocity.userdirective}")
//    private String userdirective;

    @Bean
    public FisBean fisBean(){
        FisBean fisBean = new FisBean();
        return fisBean;
    }


//    @Bean
//    public VelocityConfigurer velocityConfigurer(){
//        Map<String, Object> config = new HashMap<String, Object>();
//        config.put("userdirective", this.userdirective);
//        VelocityConfigurer velocityConfigurer = new VelocityConfigurer();
//        velocityConfigurer.setVelocityPropertiesMap(config);
//        velocityConfigurer.setResourceLoaderPath("classpath:/templates/");
//        return velocityConfigurer;
//    }
}

