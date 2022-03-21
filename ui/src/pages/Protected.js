import React from "react";
import { useAuth } from "../context/auth";

function Protected() {
    const { authTokens, isLoggedIn } = useAuth();
    return (<div>Logged In = {isLoggedIn}, authTokens = {authTokens}</div>)
}
export default Protected;
