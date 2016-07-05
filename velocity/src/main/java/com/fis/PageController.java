package com.fis;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributesModelMap;

@Controller
@RequestMapping("/")
public class PageController {
    @RequestMapping(value="{project}/page/{vm}", method = RequestMethod.GET)
    public String get(
            HttpServletRequest request,
            @PathVariable(value="project") String project,
            @PathVariable(value="vm") String vm,
            @RequestParam Map<String, String> map, Map<String, Object> model,
            RedirectAttributesModelMap redirectMap)
    {
        String page = "/page/" + vm;
        
        model.put("data", map);
        return project + page; 
    }
    
    @RequestMapping(value="{project}/page/{vm}", method = RequestMethod.POST)
    public String post(
            HttpServletRequest request,
            @PathVariable(value="project") String project,
            @PathVariable(value="vm") String vm,
            @RequestBody Map<String, Object> map, Map<String, Object> model,
            RedirectAttributesModelMap redirectMap)
    {
        String page = "/page/" + vm;
        String redirect = (String) map.get("redirect");
        if (redirect != null) {
            if (redirect.startsWith("http")) {
                return "redirect:" + redirect;
            }

            String protocol = (String) map.get("redirectProtocol");
            map.remove("redirect");
            map.remove("redirectProtocol");
            
            if ("https".equals(protocol)) {
                redirectMap.putAll(map);
                return "redirect:https://" + request.getHeader("Host") + redirect;
            } else if ("rewrite".equals(protocol)) {
                page = redirect;
            } else {
                redirectMap.putAll(map);
                return "redirect:" + redirect;
            }
        }
        
        model.putAll(map);
        return project + page;
    }
   
    @RequestMapping(value="{project}/page/{vm}/{subvm}", method = RequestMethod.GET)
    public String get1(
            HttpServletRequest request,
            @PathVariable(value="project") String project,
            @PathVariable(value="vm") String vm,
            @PathVariable(value="subvm") String subvm,
            @RequestParam Map<String, String> map, Map<String, Object> model,
            RedirectAttributesModelMap redirectMap)
    {
        String page = "/page/" + vm + "/" + subvm;
        
        model.put("data", map);
        return project + page;
    }

    @RequestMapping(value="{project}/page/{vm}/{subvm}", method = RequestMethod.POST)
    public String post1(
            HttpServletRequest request,
            @PathVariable(value="project") String project,
            @PathVariable(value="vm") String vm,
            @PathVariable(value="subvm") String subvm,
            @RequestBody Map<String, Object> map, Map<String, Object> model,
            RedirectAttributesModelMap redirectMap)
    {
        String page = "/page/" + vm + "/" + subvm;
        String redirect = (String) map.get("redirect");
        if (redirect != null) {
            if (redirect.startsWith("http")) {
                return "redirect:" + redirect;
            }

            String protocol = (String) map.get("redirectProtocol");
            map.remove("redirect");
            map.remove("redirectProtocol");
            
            if ("https".equals(protocol)) {
                redirectMap.putAll(map);
                return "redirect:https://" + request.getHeader("Host") + redirect;
            } else if ("rewrite".equals(protocol)) {
                page = redirect;
            } else {
                redirectMap.putAll(map);
                return "redirect:" + redirect;
            }
        }
        
        model.putAll(map);
        return project + page;
    }
}
