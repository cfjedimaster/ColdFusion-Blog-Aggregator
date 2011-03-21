<cfcomponent name="Core Bean" output="false">

<cffunction name="onMissingMethod" access="public" returnType="any" output="false">
	<cfargument name="missingMethodName" type="string" required="true">
	<cfargument name="missingMethodArguments" type="struct" required="true">
	<cfset var key = "">
	
	<cfif find("get", arguments.missingMethodName) is 1>
		<cfset key = replaceNoCase(arguments.missingMethodName,"get","")>
		<cfif structKeyExists(variables, key)>
			<cfreturn variables[key]>
		</cfif>
	</cfif>

	<cfif find("set", arguments.missingMethodName) is 1>
		<cfset key = replaceNoCase(arguments.missingMethodName,"set","")>
		<cfif structKeyExists(arguments.missingMethodArguments, key)>
			<cfset variables[key] = arguments.missingMethodArguments[key]>
		</cfif>
	</cfif>
	
</cffunction>

</cfcomponent>